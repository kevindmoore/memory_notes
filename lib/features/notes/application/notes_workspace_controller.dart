import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_selection.dart';
import 'package:signals/signals.dart';

class NotesWorkspaceController {
  final selection = signal(const NotesWorkspaceSelection());
  final openFileIds = listSignal<int>([]);
  final todoSearchQuery = signal('');
  final Map<int, NotesWorkspaceSelection> _savedSelectionsByFile = <int, NotesWorkspaceSelection>{};
  final Map<int, double> _desktopScrollOffsetByFile = <int, double>{};

  int? get selectedFileId => selection.value.fileId;
  int? get selectedCategoryId => selection.value.categoryId;
  int? get selectedTodoId => selection.value.todoId;
  List<int> get selectedTodoPath => selection.value.todoPath;
  Map<int, NotesWorkspaceSelection> get savedSelectionsByFile =>
      Map<int, NotesWorkspaceSelection>.unmodifiable(_savedSelectionsByFile);
  Map<int, double> get desktopScrollOffsetsByFile =>
      Map<int, double>.unmodifiable(_desktopScrollOffsetByFile);

  void restoreSavedSelections(Map<int, NotesWorkspaceSelection> selections) {
    _savedSelectionsByFile
      ..clear()
      ..addAll(selections);
  }

  void restoreDesktopScrollOffsets(Map<int, double> offsets) {
    _desktopScrollOffsetByFile
      ..clear()
      ..addAll(offsets);
  }

  void selectFile(int? fileId, {bool clearCategory = true}) {
    _cacheCurrentSelection();
    final restoredSelection = fileId == null ? null : _savedSelectionsByFile[fileId];
    final nextSelection = restoredSelection == null
        ? NotesWorkspaceSelection(
            fileId: fileId,
            categoryId: clearCategory ? null : selection.value.categoryId,
            todoId: null,
            todoPath: const <int>[],
          )
        : restoredSelection.copyWith(fileId: fileId);
    selection.value = nextSelection;
    _cacheSelection(nextSelection);
    if (fileId != null && !openFileIds.contains(fileId)) {
      openFileIds.add(fileId);
    }
  }

  void selectCategory({
    required int fileId,
    required int categoryId,
    int? todoId,
  }) {
    final nextSelection = NotesWorkspaceSelection(
      fileId: fileId,
      categoryId: categoryId,
      todoId: todoId,
      todoPath: todoId == null ? const <int>[] : <int>[todoId],
    );
    selection.value = nextSelection;
    _cacheSelection(nextSelection);
    if (!openFileIds.contains(fileId)) {
      openFileIds.add(fileId);
    }
  }

  void selectTodo({
    required int fileId,
    required int categoryId,
    required int todoId,
    required List<int> todoPath,
  }) {
    final nextSelection = NotesWorkspaceSelection(
      fileId: fileId,
      categoryId: categoryId,
      todoId: todoId,
      todoPath: todoPath,
    );
    selection.value = nextSelection;
    _cacheSelection(nextSelection);
  }

  void clearSelection() {
    _cacheCurrentSelection();
    selection.value = const NotesWorkspaceSelection();
  }

  void setOpenFileIds(List<int> fileIds) {
    openFileIds.value = fileIds.toSet().toList();
  }

  void closeFile(int fileId) {
    openFileIds.remove(fileId);
  }

  void forgetFile(int fileId) {
    _savedSelectionsByFile.remove(fileId);
    _desktopScrollOffsetByFile.remove(fileId);
  }

  void markFileUsed(int fileId) {
    final next = openFileIds.value.where((id) => id != fileId).toList();
    next.insert(0, fileId);
    openFileIds.value = next;
  }

  void syncWithData({
    required List<TodoFile> files,
    required List<Category> categories,
    required Map<int, List<Todo>> todosByCategory,
    Set<int> loadedCategoryFileIds = const <int>{},
    Set<int> loadedTodoCategoryIds = const <int>{},
  }) {
    final validFileIds = files.where((file) => file.id != null).map((file) => file.id!).toSet();
    _savedSelectionsByFile.removeWhere((fileId, _) => !validFileIds.contains(fileId));
    _desktopScrollOffsetByFile.removeWhere((fileId, _) => !validFileIds.contains(fileId));
    final nextOpenFileIds =
        openFileIds.value.where((fileId) => validFileIds.contains(fileId)).toList(growable: false);
    if (nextOpenFileIds.length != openFileIds.value.length) {
      openFileIds.value = nextOpenFileIds;
    }
    final selected = selection.value;

    if (files.isEmpty) {
      clearSelection();
      return;
    }

    final selectedFile = files.where((file) => file.id == selected.fileId).firstOrNull;
    if (selected.fileId != null && selectedFile == null) {
      selection.value = const NotesWorkspaceSelection();
      return;
    }

    if (selectedFile == null) {
      final nextSelectedFileId = nextOpenFileIds.firstOrNull;
      if (nextSelectedFileId != null) {
        selectFile(nextSelectedFileId);
      }
      return;
    }

    final fileCategories = categories.where((c) => c.todoFileId == selectedFile.id).toList();
    final selectedCategory =
        fileCategories.where((category) => category.id == selected.categoryId).firstOrNull;
    final categoriesLoadedForSelectedFile =
        selectedFile.id != null && loadedCategoryFileIds.contains(selectedFile.id!);

    if (selected.categoryId != null && selectedCategory == null) {
      if (!categoriesLoadedForSelectedFile) {
        return;
      }
      selection.value = selection.value.patch(
        clearCategory: true,
        clearTodo: true,
      );
      _cacheCurrentSelection();
      return;
    }

    if (selectedCategory == null && fileCategories.isNotEmpty && fileCategories.first.id != null) {
      if (!categoriesLoadedForSelectedFile) {
        return;
      }
      selectCategory(
        fileId: selectedFile.id!,
        categoryId: fileCategories.first.id!,
      );
      return;
    }

    if (selectedCategory == null || selectedCategory.id == null) {
      return;
    }

    final todos = todosByCategory[selectedCategory.id!] ?? const <Todo>[];
    final selectedTodo = todos.where((todo) => todo.id == selected.todoId).firstOrNull;
    final todosLoadedForSelectedCategory = loadedTodoCategoryIds.contains(selectedCategory.id!);
    if (selected.todoId != null && selectedTodo == null) {
      if (!todosLoadedForSelectedCategory) {
        return;
      }
      selection.value = selection.value.patch(clearTodo: true);
      _cacheCurrentSelection();
      return;
    }

    if (selected.todoPath.isEmpty || !todosLoadedForSelectedCategory) {
      return;
    }

    final todoIds = {for (final todo in todos) todo.id: todo};
    final nextPath = <int>[];
    int? expectedParentId;
    for (final todoId in selected.todoPath) {
      final todo = todoIds[todoId];
      if (todo == null || todo.parentTodoId != expectedParentId) {
        break;
      }
      nextPath.add(todoId);
      expectedParentId = todoId;
    }
    if (nextPath.length != selected.todoPath.length) {
      selection.value = selection.value.patch(
        todoId: nextPath.isEmpty ? null : nextPath.last,
        todoPath: nextPath,
      );
      _cacheCurrentSelection();
    }
  }

  void _cacheCurrentSelection() {
    _cacheSelection(selection.value);
  }

  void _cacheSelection(NotesWorkspaceSelection nextSelection) {
    final fileId = nextSelection.fileId;
    if (fileId == null) return;
    _savedSelectionsByFile[fileId] = nextSelection;
  }

  void saveDesktopScrollOffset({
    required int fileId,
    required double offset,
  }) {
    _desktopScrollOffsetByFile[fileId] = offset;
  }

  double desktopScrollOffsetForFile(int fileId) => _desktopScrollOffsetByFile[fileId] ?? 0;
}
