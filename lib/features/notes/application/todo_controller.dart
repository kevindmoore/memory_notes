import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:signals/signals.dart';

class TodoController {
  final TodoRepository _todoRepo;
  final CategoryController? _categories;
  final TodoFileController? _todoFiles;

  TodoController(
    this._todoRepo, {
    CategoryController? categories,
    TodoFileController? todoFiles,
  }) : _categories = categories,
       _todoFiles = todoFiles;

  final todosByCategory = mapSignal<int, List<Todo>>({});
  final loadedTodoCategoryIds = listSignal<int>([]);

  Future<void> loadTodos(int categoryId) async {
    try {
      final result = await _todoRepo.getByCategory(categoryId);
      todosByCategory[categoryId] = result;
      if (!loadedTodoCategoryIds.contains(categoryId)) {
        loadedTodoCategoryIds.add(categoryId);
      }
    } catch (e) {
      logError('TodoController.loadTodos: $e');
    }
  }

  List<Todo> getTodosForCategory(int categoryId) => todosByCategory[categoryId] ?? [];

  Future<Todo?> addTodo(
    int todoFileId,
    int categoryId,
    String name, {
    int? parentTodoId,
    String notes = '',
    bool done = false,
    bool visible = true,
    bool expanded = false,
    int order = 0,
  }) async {
    try {
      final todo = Todo(
        name: name,
        todoFileId: todoFileId,
        categoryId: categoryId,
        parentTodoId: parentTodoId,
        notes: notes,
        done: done,
        visible: visible,
        expanded: expanded,
        order: order,
        lastUpdated: DateTime.now(),
      );
      final created = await _todoRepo.add(todo, todoFileId, categoryId);
      if (created != null) {
        final current = List<Todo>.from(todosByCategory[categoryId] ?? []);
        current.add(created);
        todosByCategory[categoryId] = current;
        await _touchAncestors(
          todo: created,
          timestamp: created.lastUpdated ?? DateTime.now(),
        );
      }
      return created;
    } catch (e) {
      logError('TodoController.addTodo: $e');
    }
    return null;
  }

  Future<Todo?> toggleDone(Todo todo) async {
    try {
      final timestamp = DateTime.now();
      final updated = await _todoRepo.update(
        todo.copyWith(done: !todo.done, lastUpdated: timestamp),
        todo.todoFileId!,
        todo.categoryId!,
      );
      if (updated != null) {
        _replaceTodo(updated);
        await _touchAncestors(todo: updated, timestamp: timestamp);
      }
      return updated;
    } catch (e) {
      logError('TodoController.toggleDone: $e');
    }
    return null;
  }

  Future<Todo?> updateTodo(Todo todo) async {
    try {
      final current = await _findCurrentTodo(todo);
      if (current != null && _hasSameMutableValues(current, todo)) {
        return current;
      }
      final timestamp = DateTime.now();
      final updated = await _todoRepo.update(
        todo.copyWith(lastUpdated: timestamp),
        todo.todoFileId!,
        todo.categoryId!,
      );
      if (updated != null) {
        _replaceTodo(updated);
        await _touchAncestors(todo: updated, timestamp: timestamp);
      }
      return updated;
    } catch (e) {
      logError('TodoController.updateTodo: $e');
    }
    return null;
  }

  Future<Todo?> renameTodo(Todo todo, String name) async {
    try {
      if (todo.name == name) {
        return todo;
      }
      final timestamp = DateTime.now();
      final updated = await _todoRepo.update(
        todo.copyWith(name: name, lastUpdated: timestamp),
        todo.todoFileId!,
        todo.categoryId!,
      );
      if (updated != null) {
        _replaceTodo(updated);
        await _touchAncestors(todo: updated, timestamp: timestamp);
      }
      return updated;
    } catch (e) {
      logError('TodoController.renameTodo: $e');
    }
    return null;
  }

  Future<void> deleteTodo(Todo todo) async {
    try {
      final timestamp = DateTime.now();
      await _todoRepo.delete(todo.id!);
      removeTodoById(
        categoryId: todo.categoryId,
        todoId: todo.id,
      );
      await _touchAncestors(
        todo: todo,
        timestamp: timestamp,
      );
    } catch (e) {
      logError('TodoController.deleteTodo: $e');
    }
  }

  void removeTodoById({
    required int? categoryId,
    required int? todoId,
  }) {
    if (categoryId == null || todoId == null) return;
    final current = List<Todo>.from(todosByCategory[categoryId] ?? []);
    current.removeWhere((t) => t.id == todoId);
    todosByCategory[categoryId] = current;
  }

  void _replaceTodo(Todo updated) {
    final current = List<Todo>.from(todosByCategory[updated.categoryId] ?? []);
    final idx = current.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      current[idx] = updated;
      todosByCategory[updated.categoryId!] = current;
    }
  }

  Future<Todo?> _findCurrentTodo(Todo todo) async {
    final categoryId = todo.categoryId;
    if (categoryId == null) return null;
    final local = getTodosForCategory(categoryId).where((item) => item.id == todo.id).firstOrNull;
    if (local != null) {
      return local;
    }
    final remote = await _todoRepo.getByCategory(categoryId);
    return remote.where((item) => item.id == todo.id).firstOrNull;
  }

  bool _hasSameMutableValues(Todo current, Todo next) {
    return current.name == next.name &&
        current.done == next.done &&
        current.visible == next.visible &&
        current.expanded == next.expanded &&
        current.order == next.order &&
        current.parentTodoId == next.parentTodoId &&
        current.notes == next.notes;
  }

  Future<void> _touchAncestors({
    required Todo todo,
    required DateTime timestamp,
  }) async {
    final fileId = todo.todoFileId;
    final categoryId = todo.categoryId;
    if (fileId == null || categoryId == null) return;

    await _touchParentTodos(
      categoryId: categoryId,
      startingParentTodoId: todo.parentTodoId,
      timestamp: timestamp,
    );
    await _categories?.touchCategory(
      categoryId: categoryId,
      todoFileId: fileId,
      timestamp: timestamp,
    );
    await _todoFiles?.touchFile(fileId, timestamp: timestamp);
  }

  Future<void> _touchParentTodos({
    required int categoryId,
    required int? startingParentTodoId,
    required DateTime timestamp,
  }) async {
    if (startingParentTodoId == null) return;
    final allTodos = await _allTodosForCategory(categoryId);
    if (allTodos.isEmpty) return;

    final todoById = <int, Todo>{
      for (final todo in allTodos)
        if (todo.id != null) todo.id!: todo,
    };

    int? parentId = startingParentTodoId;
    while (parentId != null) {
      final parent = todoById[parentId];
      if (parent == null || parent.todoFileId == null || parent.categoryId == null) {
        break;
      }
      final didTouch = await _todoRepo.touchLastUpdated(parentId, timestamp);
      if (!didTouch) {
        break;
      }
      final updated = parent.copyWith(lastUpdated: timestamp);
      todoById[parentId] = updated;
      _replaceTodo(updated);
      parentId = updated.parentTodoId;
    }
  }

  Future<List<Todo>> _allTodosForCategory(int categoryId) async {
    final local = getTodosForCategory(categoryId);
    if (local.isNotEmpty) {
      return local;
    }
    return _todoRepo.getByCategory(categoryId);
  }
}
