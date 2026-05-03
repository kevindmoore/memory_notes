import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/mobile_note_detail_view_state.dart';
import 'package:memory_notes/features/notes/models/mobile_note_edit_view_state.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';

class NotesMobileStore {
  NotesMobileStore({
    required this.todoFiles,
    required this.categories,
    required this.todos,
    required this.query,
  });

  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;
  final NotesQueryService query;

  Future<void> loadFile(int fileId) => categories.loadCategories(fileId);

  Future<void> loadCategory(int categoryId) => todos.loadTodos(categoryId);

  Future<Category?> createCategory({
    required int fileId,
    required String name,
  }) {
    return categories.createCategory(fileId, name);
  }

  Future<void> renameList(TodoFile file, String name) {
    final duplicate = todoFiles.findByName(name, excludingId: file.id);
    if (duplicate != null) {
      return Future.value();
    }
    return todoFiles.update(
      file.copyWith(name: name, lastUpdated: DateTime.now()),
    );
  }

  Future<TodoFile?> duplicateList(
    TodoFile file, {
    String? name,
  }) {
    final targetName = name ?? '${file.name} (Copy)';
    final duplicate = todoFiles.findByName(targetName);
    if (duplicate != null) {
      return Future.value(duplicate);
    }
    return todoFiles.create(targetName);
  }

  Future<void> deleteList(int fileId) {
    return todoFiles.delete(fileId);
  }

  Future<void> renameCategory(Category category, String name) {
    return categories.renameCategory(category, name);
  }

  Future<void> deleteCategory(int categoryId) {
    todos.todosByCategory.remove(categoryId);
    return categories.deleteCategory(categoryId);
  }

  Future<void> addTodo({
    required int fileId,
    required int categoryId,
    required String name,
    int? parentTodoId,
  }) {
    return todos.addTodo(
      fileId,
      categoryId,
      name,
      parentTodoId: parentTodoId,
    );
  }

  Future<void> addNote({
    required int fileId,
    required int categoryId,
    required String notes,
    int? parentTodoId,
  }) {
    return todos.addTodo(
      fileId,
      categoryId,
      'Note',
      parentTodoId: parentTodoId,
      notes: notes,
    );
  }

  Future<void> saveTodoNotes(Todo todo, String notes) async {
    if (notes == todo.notes) return;
    await todos.updateTodo(todo.copyWith(notes: notes));
  }

  Future<void> toggleTodo(Todo todo) {
    return todos.toggleDone(todo);
  }

  Future<void> renameTodo(Todo todo, String name) {
    return todos.renameTodo(todo, name);
  }

  Future<void> deleteTodo(Todo todo) {
    return todos.deleteTodo(todo);
  }

  MobileNoteEditViewState buildNoteEditViewState({
    required int fileId,
    required int categoryId,
    int? parentTodoId,
    int? focusedTodoId,
    String searchQuery = '',
    bool openFocusedTodoNotes = false,
    TodoSortOrder todoSortOrder = TodoSortOrder.newest,
  }) {
    final fileName = query.findFileById(todoFiles.todoFiles.value, fileId)?.name ?? '';
    final category = query.findCategoryById(categories.categories.value, categoryId);
    final allTodos = query.sortTodos(
      query.todosForCategory(todos.todosByCategory.value, categoryId),
      sortOrder: todoSortOrder,
    );
    final parentTodo = query.findTodoById(allTodos, parentTodoId);
    final focusedTodo = query.findTodoById(allTodos, focusedTodoId);
    final levelTodos =
        allTodos.where((todo) => todo.parentTodoId == parentTodoId).toList(growable: false);
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final visibleTodos = normalizedQuery.isEmpty
        ? levelTodos
        : levelTodos
            .where((todo) => todo.name.toLowerCase().contains(normalizedQuery))
            .toList(growable: false);

    return MobileNoteEditViewState(
      fileName: fileName,
      category: category,
      parentTodo: parentTodo,
      focusedTodo: focusedTodo,
      screenTitle: openFocusedTodoNotes
          ? (focusedTodo?.name ?? 'Todo Notes')
          : (parentTodo?.name ?? category?.name ?? ''),
      allTodos: allTodos,
      visibleTodos: visibleTodos,
    );
  }

  MobileNoteDetailViewState buildNoteDetailViewState({
    required int fileId,
    String searchQuery = '',
    CategorySortOrder categorySortOrder = CategorySortOrder.newest,
  }) {
    final fileName = query.findFileById(todoFiles.todoFiles.value, fileId)?.name ?? 'Note List';
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final categoryItems = query
        .sortCategories(
      query.categoriesForFile(categories.categories.value, fileId),
      sortOrder: categorySortOrder,
      todosByCategory: todos.todosByCategory.value,
    )
        .where((category) {
      if (normalizedQuery.isEmpty) {
        return true;
      }
      if (category.name.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
      final categoryTodos = query.todosForCategory(todos.todosByCategory.value, category.id);
      return categoryTodos.any((todo) => todo.name.toLowerCase().contains(normalizedQuery));
    }).map((category) {
      return MobileNoteDetailCategoryItem(
        category: category,
        topLevelTodoCount: query.topLevelTodoCount(
          todos.todosByCategory.value,
          category.id,
        ),
      );
    }).toList(growable: false);

    return MobileNoteDetailViewState(
      fileName: fileName,
      categories: categoryItems,
      isLoading: categories.isLoading.value && categories.categories.value.isEmpty,
    );
  }
}
