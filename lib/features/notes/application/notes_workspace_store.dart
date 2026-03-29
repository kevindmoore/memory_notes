import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_selection.dart';
import 'package:memory_notes/features/notes/models/notes_sort_order.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_view_state.dart';

class NotesWorkspaceStore {
  NotesWorkspaceStore({
    required this.workspace,
    required this.currentState,
    required this.query,
    required this.todoFiles,
    required this.categories,
    required this.todos,
  });

  final NotesWorkspaceController workspace;
  final CurrentStateRepository currentState;
  final NotesQueryService query;
  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;

  NotesWorkspaceViewState buildViewState({
    required NotesSortOrder sortOrder,
    CategorySortOrder categorySortOrder = CategorySortOrder.newest,
    TodoSortOrder todoSortOrder = TodoSortOrder.newest,
  }) {
    final allFiles = todoFiles.todoFiles.value;
    final openFileIds = query.normalizeFileIds(workspace.openFileIds.value, allFiles);
    final files = query.sortFiles(allFiles, sortOrder: sortOrder);
    final allCategories = categories.categories.value;
    final selectedFile = query.findFileById(files, workspace.selectedFileId);
    final selectedCategory = query.findCategoryById(allCategories, workspace.selectedCategoryId);
    final selectedCategoryTodos = query.sortTodos(
      query.todosForCategory(todos.todosByCategory.value, selectedCategory?.id),
      sortOrder: todoSortOrder,
    );
    final openFiles = query.sortFiles(
      files.where((file) => file.id != null && openFileIds.contains(file.id!)),
      sortOrder: sortOrder,
    );
    final availableFiles = query.sortFiles(
      files.where((file) => file.id == null || !openFileIds.contains(file.id!)),
      sortOrder: sortOrder,
    );

    return NotesWorkspaceViewState(
      files: files,
      fileItems: files
          .map(
            (file) => DesktopWorkspaceFileItem(
              file: file,
              categoryCount:
                  allCategories.where((category) => category.todoFileId == file.id).length,
              isSelected: file.id == workspace.selectedFileId,
              isOpen: file.id != null && openFileIds.contains(file.id!),
            ),
          )
          .toList(growable: false),
      openFileItems: openFiles
          .map(
            (file) => DesktopWorkspaceFileItem(
              file: file,
              categoryCount:
                  allCategories.where((category) => category.todoFileId == file.id).length,
              isSelected: file.id == workspace.selectedFileId,
              isOpen: true,
            ),
          )
          .toList(growable: false),
      availableFileItems: availableFiles
          .map(
            (file) => DesktopWorkspaceFileItem(
              file: file,
              categoryCount:
                  allCategories.where((category) => category.todoFileId == file.id).length,
              isSelected: file.id == workspace.selectedFileId,
              isOpen: false,
            ),
          )
          .toList(growable: false),
      openFileIds: openFileIds,
      selectedFile: selectedFile,
      selectedCategory: selectedCategory,
      categories: selectedFile == null
          ? const <Category>[]
          : query.sortCategories(
              query.categoriesForFile(allCategories, selectedFile.id),
              sortOrder: categorySortOrder,
              todosByCategory: todos.todosByCategory.value,
            ),
      todos: selectedCategoryTodos,
      selectedTodo: query.findTodoById(selectedCategoryTodos, workspace.selectedTodoId),
      selectedTodoPath: workspace.selectedTodoPath,
    );
  }

  Future<void> initialize() async {
    await todoFiles.load();
    final savedWorkspaceState = await currentState.getWorkspaceState();
    final restoredFileIds = query.normalizeFileIds(
      savedWorkspaceState.openFileIds,
      todoFiles.todoFiles.value,
    );
    final validFileIds =
        todoFiles.todoFiles.value.where((file) => file.id != null).map((file) => file.id!).toSet();
    workspace.restoreSavedSelections({
      for (final entry in savedWorkspaceState.selectionsByFile.entries)
        if (validFileIds.contains(entry.key))
          entry.key: NotesWorkspaceSelection(
            fileId: entry.key,
            categoryId: entry.value.categoryId,
            todoId: entry.value.todoId,
            todoPath: entry.value.todoPath,
          ),
    });
    workspace.restoreDesktopScrollOffsets({
      for (final entry in savedWorkspaceState.selectionsByFile.entries)
        if (validFileIds.contains(entry.key)) entry.key: entry.value.desktopScrollOffset,
    });
    workspace.setOpenFileIds(restoredFileIds);
    final restoredSelectedFileId = savedWorkspaceState.selectedFileId;
    if (restoredSelectedFileId != null && validFileIds.contains(restoredSelectedFileId)) {
      workspace.selectFile(restoredSelectedFileId);
    } else if (restoredFileIds.isNotEmpty) {
      workspace.selectFile(restoredFileIds.first);
    }
    final fileIds =
        todoFiles.todoFiles.value.where((file) => file.id != null).map((file) => file.id!).toList();
    await categories.loadCategoriesForFiles(fileIds);
    if (workspace.selectedFileId != null) {
      await _loadTodosForFileCategories(workspace.selectedFileId!);
    } else if (workspace.selectedCategoryId != null) {
      await todos.loadTodos(workspace.selectedCategoryId!);
    }
    syncWorkspace();
  }

  void syncWorkspace() {
    final previous = workspace.selection.value;
    workspace.syncWithData(
      files: todoFiles.todoFiles.value,
      categories: categories.categories.value,
      todosByCategory: todos.todosByCategory.value,
      loadedCategoryFileIds: categories.loadedCategoryFileIds.value.toSet(),
      loadedTodoCategoryIds: todos.loadedTodoCategoryIds.value.toSet(),
    );
    final current = workspace.selection.value;

    if (current.fileId != null &&
        current.fileId != previous.fileId &&
        !categories.loadedCategoryFileIds.contains(current.fileId!)) {
      categories.loadCategories(current.fileId!);
    }
    if (current.categoryId != null && current.categoryId != previous.categoryId) {
      todos.loadTodos(current.categoryId!);
    }
    if (current != previous) {
      persistCurrentFiles();
    }
  }

  Future<void> selectFile(TodoFile file, {bool autoSelectFirstCategory = false}) async {
    final fileId = file.id;
    if (fileId == null) return;

    workspace.selectFile(fileId);
    workspace.markFileUsed(fileId);
    await persistCurrentFiles();
    if (!categories.loadedCategoryFileIds.contains(fileId)) {
      await categories.loadCategories(fileId);
    }
    await _loadTodosForFileCategories(fileId);

    final restoredCategoryId =
        workspace.selectedFileId == fileId ? workspace.selectedCategoryId : null;
    if (restoredCategoryId != null) {
      await todos.loadTodos(restoredCategoryId);
    }

    if (autoSelectFirstCategory) {
      final fileCategories =
          categories.categories.value.where((category) => category.todoFileId == fileId).toList();

      if (fileCategories.isNotEmpty && fileCategories.first.id != null) {
        workspace.selectCategory(
          fileId: fileId,
          categoryId: fileCategories.first.id!,
        );
        await todos.loadTodos(fileCategories.first.id!);
      }
    }

    syncWorkspace();
  }

  Future<void> closeFile(TodoFile file) async {
    final fileId = file.id;
    if (fileId == null) return;

    workspace.closeFile(fileId);
    if (workspace.selectedFileId == fileId) {
      final nextOpenFileId = workspace.openFileIds.value.firstOrNull;
      if (nextOpenFileId != null) {
        workspace.selectFile(nextOpenFileId);
      } else {
        workspace.clearSelection();
      }
    }
    workspace.forgetFile(fileId);
    await persistCurrentFiles();
    syncWorkspace();
  }

  Future<void> reloadFile(int fileId) async {
    final didRefreshFiles = await _reloadFilesPreservingExistingOnEmptyResult();
    if (!didRefreshFiles) return;

    final previousCategoryIds = categories.categories.value
        .where((category) => category.todoFileId == fileId)
        .map((category) => category.id)
        .whereType<int>()
        .toSet();

    await categories.loadCategories(fileId);

    final nextCategoryIds = categories.categories.value
        .where((category) => category.todoFileId == fileId)
        .map((category) => category.id)
        .whereType<int>()
        .toSet();

    for (final removedCategoryId in previousCategoryIds.difference(nextCategoryIds)) {
      todos.todosByCategory.remove(removedCategoryId);
    }

    await _loadTodosForFileCategories(fileId, forceReload: true);
    syncWorkspace();
    await persistCurrentFiles();
  }

  Future<void> reloadOpenFiles() async {
    final didRefreshFiles = await _reloadFilesPreservingExistingOnEmptyResult();
    if (!didRefreshFiles) return;

    final openFileIds =
        query.normalizeFileIds(workspace.openFileIds.value, todoFiles.todoFiles.value);
    final previousCategoryIdsByFile = <int, Set<int>>{
      for (final fileId in openFileIds)
        fileId: categories.categories.value
            .where((category) => category.todoFileId == fileId)
            .map((category) => category.id)
            .whereType<int>()
            .toSet(),
    };

    await categories.loadCategoriesForFiles(openFileIds);

    for (final fileId in openFileIds) {
      final nextCategoryIds = categories.categories.value
          .where((category) => category.todoFileId == fileId)
          .map((category) => category.id)
          .whereType<int>()
          .toSet();
      for (final removedCategoryId
          in (previousCategoryIdsByFile[fileId] ?? const <int>{}).difference(nextCategoryIds)) {
        todos.todosByCategory.remove(removedCategoryId);
      }
      await _loadTodosForFileCategories(fileId, forceReload: true);
    }

    syncWorkspace();
    await persistCurrentFiles();
  }

  Future<void> reloadAllFiles() async {
    final didRefreshFiles = await _reloadFilesPreservingExistingOnEmptyResult();
    if (!didRefreshFiles) return;

    final allFileIds = todoFiles.todoFiles.value
        .where((file) => file.id != null)
        .map((file) => file.id!)
        .toList(growable: false);
    final previouslyLoadedCategoryIds =
        categories.categories.value.map((category) => category.id).whereType<int>().toSet();

    if (allFileIds.isNotEmpty) {
      await categories.loadCategoriesForFiles(allFileIds);
    }

    final nextCategoryIds =
        categories.categories.value.map((category) => category.id).whereType<int>().toSet();
    for (final removedCategoryId in previouslyLoadedCategoryIds.difference(nextCategoryIds)) {
      todos.todosByCategory.remove(removedCategoryId);
    }

    final openFileIds =
        query.normalizeFileIds(workspace.openFileIds.value, todoFiles.todoFiles.value).toSet();
    final categoryIdsToReload = <int>{
      ...todos.loadedTodoCategoryIds.value,
      for (final category in categories.categories.value)
        if (category.id != null && openFileIds.contains(category.todoFileId)) category.id!,
    };
    for (final categoryId in categoryIdsToReload) {
      if (nextCategoryIds.contains(categoryId)) {
        await todos.loadTodos(categoryId);
      }
    }

    syncWorkspace();
    await persistCurrentFiles();
  }

  Future<void> selectCategory({
    required TodoFile file,
    required Category category,
  }) async {
    final fileId = file.id;
    final categoryId = category.id;
    if (fileId == null || categoryId == null) return;

    workspace.selectCategory(fileId: fileId, categoryId: categoryId);
    await todos.loadTodos(categoryId);
    await persistCurrentFiles();
    syncWorkspace();
  }

  void selectTodo({
    required int fileId,
    required int categoryId,
    required List<int> todoPath,
  }) {
    if (todoPath.isEmpty) return;
    workspace.selectTodo(
      fileId: fileId,
      categoryId: categoryId,
      todoId: todoPath.last,
      todoPath: todoPath,
    );
    syncWorkspace();
    persistCurrentFiles();
  }

  Future<void> persistCurrentFiles() {
    final fileIds = query.normalizeFileIds(workspace.openFileIds.value, todoFiles.todoFiles.value);
    final validFileIds =
        todoFiles.todoFiles.value.where((file) => file.id != null).map((file) => file.id!).toSet();
    final selectionsByFile = <int, PersistedWorkspaceSelection>{};
    final persistedFileIds = <int>{
      ...workspace.savedSelectionsByFile.keys,
      ...workspace.desktopScrollOffsetsByFile.keys,
    };
    for (final fileId in persistedFileIds) {
      if (!validFileIds.contains(fileId)) continue;
      final selection = workspace.savedSelectionsByFile[fileId];
      selectionsByFile[fileId] = PersistedWorkspaceSelection(
        categoryId: selection?.categoryId,
        todoId: selection?.todoId,
        todoPath: selection?.todoPath ?? const <int>[],
        desktopScrollOffset: workspace.desktopScrollOffsetForFile(fileId),
      );
    }
    final selectedFileId =
        workspace.selectedFileId != null && validFileIds.contains(workspace.selectedFileId)
            ? workspace.selectedFileId
            : null;
    return currentState.saveWorkspaceState(
      openFileIds: fileIds,
      selectedFileId: selectedFileId,
      selectionsByFile: selectionsByFile,
    );
  }

  Future<void> saveDesktopScrollOffset({
    required int fileId,
    required double offset,
  }) async {
    workspace.saveDesktopScrollOffset(fileId: fileId, offset: offset);
    await persistCurrentFiles();
  }

  double desktopScrollOffsetForFile(int fileId) => workspace.desktopScrollOffsetForFile(fileId);

  Future<TodoFile?> createList(String name) async {
    final newFile = await todoFiles.create(name);
    if (newFile != null) {
      await selectFile(newFile);
    }
    return newFile;
  }

  Future<Category?> createCategory(TodoFile file, String name) async {
    final fileId = file.id;
    if (fileId == null) return null;

    final category = await categories.createCategory(fileId, name);
    if (category != null) {
      await selectCategory(file: file, category: category);
    }
    return category;
  }

  Future<void> createQuickNote(Category category, String text) async {
    final categoryId = category.id;
    final fileId = category.todoFileId;
    if (categoryId == null || fileId == null) return;

    await todos.addTodo(
      fileId,
      categoryId,
      'Note',
      notes: text,
    );
    syncWorkspace();
  }

  Future<void> renameList(TodoFile file, String name) async {
    await todoFiles.update(file.copyWith(name: name));
    await persistCurrentFiles();
    syncWorkspace();
  }

  Future<void> renameTodo(Todo todo, String name) async {
    await todos.renameTodo(todo, name);
    syncWorkspace();
  }

  Future<Todo?> addTodo({
    required int fileId,
    required int categoryId,
    required String text,
    int? parentTodoId,
  }) async {
    final created = await todos.addTodo(
      fileId,
      categoryId,
      text,
      parentTodoId: parentTodoId,
    );
    if (created?.id != null) {
      final allTodos = query.todosForCategory(todos.todosByCategory.value, categoryId);
      final todoPath = <int>[
        ...query.buildAncestorTodoIds(created!, allTodos),
        created.id!,
      ];
      final createdId = created.id!;
      workspace.selectTodo(
        fileId: fileId,
        categoryId: categoryId,
        todoId: createdId,
        todoPath: todoPath,
      );
    }
    syncWorkspace();
    return created;
  }

  Future<void> saveTodoNotes(Todo todo, String notes) async {
    if (notes == todo.notes) return;
    await todos.updateTodo(todo.copyWith(notes: notes));
    syncWorkspace();
  }

  Future<void> renameCategory(Category category, String name) async {
    await categories.renameCategory(category, name);
    syncWorkspace();
  }

  Future<void> deleteCategory({
    required Category category,
    required TodoFile file,
  }) async {
    final categoryId = category.id;
    if (categoryId == null) return;

    await categories.deleteCategory(categoryId);
    todos.todosByCategory.remove(categoryId);
    workspace.selectFile(file.id);
    await persistCurrentFiles();
    syncWorkspace();
  }

  Future<void> _loadTodosForFileCategories(
    int fileId, {
    bool forceReload = false,
  }) async {
    final fileCategories = query.categoriesForFile(categories.categories.value, fileId);
    for (final category in fileCategories) {
      final categoryId = category.id;
      if (categoryId == null) {
        continue;
      }
      if (!forceReload && todos.loadedTodoCategoryIds.contains(categoryId)) {
        continue;
      }
      await todos.loadTodos(categoryId);
    }
  }

  Future<bool> _reloadFilesPreservingExistingOnEmptyResult() async {
    final previousFiles = List<TodoFile>.from(todoFiles.todoFiles.value);
    await todoFiles.load();

    final nextFiles = todoFiles.todoFiles.value;
    final shouldPreservePreviousFiles = previousFiles.isNotEmpty && nextFiles.isEmpty;
    if (shouldPreservePreviousFiles) {
      todoFiles.todoFiles.value = previousFiles;
      return false;
    }

    return true;
  }
}
