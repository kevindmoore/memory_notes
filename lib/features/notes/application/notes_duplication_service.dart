import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';

class NotesDuplicationService {
  NotesDuplicationService({
    required this.todoFiles,
    required this.categories,
    required this.todos,
    required this.query,
  });

  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;
  final NotesQueryService query;

  Future<TodoFile?> duplicateList(
    TodoFile file, {
    String? name,
  }) async {
    final fileId = file.id;
    if (fileId == null) return null;

    await _ensureFileLoaded(fileId);

    final duplicatedFile = await todoFiles.create(name ?? '${file.name} (Copy)');
    final duplicatedFileId = duplicatedFile?.id;
    if (duplicatedFile == null || duplicatedFileId == null) {
      return duplicatedFile;
    }

    final sourceCategories = query.categoriesForFile(categories.categories.value, fileId);
    for (final category in sourceCategories) {
      await duplicateCategory(
        category,
        targetFileId: duplicatedFileId,
      );
    }

    return duplicatedFile;
  }

  Future<Category?> duplicateCategory(
    Category category, {
    String? name,
    int? targetFileId,
  }) async {
    final sourceFileId = category.todoFileId;
    final categoryId = category.id;
    final destinationFileId = targetFileId ?? sourceFileId;
    if (sourceFileId == null || categoryId == null || destinationFileId == null) {
      return null;
    }

    await _ensureCategoryLoaded(category);

    final duplicatedCategory = await categories.createCategory(
      destinationFileId,
      name ?? '${category.name} (Copy)',
    );
    final duplicatedCategoryId = duplicatedCategory?.id;
    if (duplicatedCategory == null || duplicatedCategoryId == null) {
      return duplicatedCategory;
    }

    final sourceTodos = query.todosForCategory(todos.todosByCategory.value, categoryId);
    await _duplicateTodoChildren(
      sourceTodos: sourceTodos,
      targetFileId: destinationFileId,
      targetCategoryId: duplicatedCategoryId,
      sourceParentTodoId: null,
      targetParentTodoId: null,
    );

    return duplicatedCategory;
  }

  Future<Todo?> duplicateTodo(
    Todo todo, {
    String? name,
  }) async {
    final fileId = todo.todoFileId;
    final categoryId = todo.categoryId;
    final todoId = todo.id;
    if (fileId == null || categoryId == null || todoId == null) {
      return null;
    }

    await _ensureCategoryLoaded(
      Category(name: '', id: categoryId, todoFileId: fileId),
    );

    final sourceTodos = query.todosForCategory(todos.todosByCategory.value, categoryId);
    final duplicatedRoot = await _cloneTodo(
      todo,
      targetFileId: fileId,
      targetCategoryId: categoryId,
      targetParentTodoId: todo.parentTodoId,
      nameOverride: name ?? '${todo.name} (Copy)',
    );
    final duplicatedRootId = duplicatedRoot?.id;
    if (duplicatedRoot == null || duplicatedRootId == null) {
      return duplicatedRoot;
    }

    await _duplicateTodoChildren(
      sourceTodos: sourceTodos,
      targetFileId: fileId,
      targetCategoryId: categoryId,
      sourceParentTodoId: todoId,
      targetParentTodoId: duplicatedRootId,
    );

    return duplicatedRoot;
  }

  Future<void> _ensureFileLoaded(int fileId) async {
    if (!categories.loadedCategoryFileIds.contains(fileId)) {
      await categories.loadCategories(fileId);
    }
    final fileCategories = query.categoriesForFile(categories.categories.value, fileId);
    for (final category in fileCategories) {
      await _ensureCategoryLoaded(category);
    }
  }

  Future<void> _ensureCategoryLoaded(Category category) async {
    final fileId = category.todoFileId;
    final categoryId = category.id;
    if (fileId != null && !categories.loadedCategoryFileIds.contains(fileId)) {
      await categories.loadCategories(fileId);
    }
    if (categoryId != null && !todos.todosByCategory.value.containsKey(categoryId)) {
      await todos.loadTodos(categoryId);
    }
  }

  Future<void> _duplicateTodoChildren({
    required List<Todo> sourceTodos,
    required int targetFileId,
    required int targetCategoryId,
    required int? sourceParentTodoId,
    required int? targetParentTodoId,
  }) async {
    final children = sourceTodos
        .where((todo) => todo.parentTodoId == sourceParentTodoId)
        .toList(growable: false);

    for (final child in children) {
      final duplicatedChild = await _cloneTodo(
        child,
        targetFileId: targetFileId,
        targetCategoryId: targetCategoryId,
        targetParentTodoId: targetParentTodoId,
      );
      if (duplicatedChild?.id == null || child.id == null) {
        continue;
      }
      await _duplicateTodoChildren(
        sourceTodos: sourceTodos,
        targetFileId: targetFileId,
        targetCategoryId: targetCategoryId,
        sourceParentTodoId: child.id,
        targetParentTodoId: duplicatedChild!.id,
      );
    }
  }

  Future<Todo?> _cloneTodo(
    Todo source, {
    required int targetFileId,
    required int targetCategoryId,
    required int? targetParentTodoId,
    String? nameOverride,
  }) {
    return todos.addTodo(
      targetFileId,
      targetCategoryId,
      nameOverride ?? source.name,
      parentTodoId: targetParentTodoId,
      notes: source.notes,
      done: source.done,
      visible: source.visible,
      expanded: source.expanded,
      order: source.order,
    );
  }
}
