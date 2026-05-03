import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_merge_service.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  group('NotesMergeService', () {
    test('merges duplicate lists into the preferred file', () async {
      final todoFiles = TodoFileController(
        _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Work'),
          const TodoFile(id: 2, name: 'work'),
        ]),
      );
      final categories = CategoryController(
        _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
          2: [const Category(id: 20, name: 'Ideas', todoFileId: 2)],
        }),
        todoFiles: todoFiles,
      );
      final todos = TodoController(
        _FakeTodoRepository({
          10: const [Todo(id: 100, name: 'Keep', todoFileId: 1, categoryId: 10)],
          20: const [Todo(id: 200, name: 'Move', todoFileId: 2, categoryId: 20)],
        }),
        categories: categories,
        todoFiles: todoFiles,
      );
      final service = NotesMergeService(
        todoFiles: todoFiles,
        categories: categories,
        todos: todos,
        query: const NotesQueryService(),
      );

      await todoFiles.load();
      await categories.loadCategoriesForFiles(const [1, 2]);
      await todos.loadTodos(10);
      await todos.loadTodos(20);

      final result = await service.mergeDuplicateLists(preferredFileId: 2);

      expect(result.didMerge, isTrue);
      expect(result.primaryFile?.id, 2);
      expect(todoFiles.todoFiles.value.map((file) => file.id).toList(), [2]);
      expect(
        categories.categories.value.where((category) => category.todoFileId == 2).map((c) => c.id),
        containsAll([10, 20]),
      );
      expect(
        todos.todosByCategory.value[20]?.map((todo) => todo.name).toList(),
        ['Move'],
      );
    });

    test('merges duplicate categories while merging duplicate lists', () async {
      final todoFiles = TodoFileController(
        _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Work'),
          const TodoFile(id: 2, name: 'Work'),
        ]),
      );
      final categories = CategoryController(
        _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
          2: [const Category(id: 20, name: 'Inbox', todoFileId: 2)],
        }),
        todoFiles: todoFiles,
      );
      final todos = TodoController(
        _FakeTodoRepository({
          10: const [Todo(id: 100, name: 'First', todoFileId: 1, categoryId: 10)],
          20: const [
            Todo(id: 200, name: 'Second', todoFileId: 2, categoryId: 20),
            Todo(id: 201, name: 'Child', todoFileId: 2, categoryId: 20, parentTodoId: 200),
          ],
        }),
        categories: categories,
        todoFiles: todoFiles,
      );
      final service = NotesMergeService(
        todoFiles: todoFiles,
        categories: categories,
        todos: todos,
        query: const NotesQueryService(),
      );

      await todoFiles.load();
      await categories.loadCategoriesForFiles(const [1, 2]);
      await todos.loadTodos(10);
      await todos.loadTodos(20);

      final result = await service.mergeDuplicateLists(preferredFileId: 1);

      expect(result.didMerge, isTrue);
      expect(result.mergedCategoryCount, 1);
      expect(todoFiles.todoFiles.value.single.id, 1);
      expect(
        categories.categories.value.where((category) => category.todoFileId == 1).length,
        1,
      );
      expect(
        todos.todosByCategory.value[10]?.map((todo) => todo.id).toSet(),
        {100, 200, 201},
      );
      final movedChild = todos.todosByCategory.value[10]!.where((todo) => todo.id == 201).single;
      expect(movedChild.parentTodoId, 200);
    });

    test('preserves same-named todos that exist in different paths', () async {
      final todoFiles = TodoFileController(
        _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Work'),
          const TodoFile(id: 2, name: 'Work'),
        ]),
      );
      final categories = CategoryController(
        _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
          2: [const Category(id: 20, name: 'Inbox', todoFileId: 2)],
        }),
        todoFiles: todoFiles,
      );
      final todos = TodoController(
        _FakeTodoRepository({
          10: const [
            Todo(id: 100, name: 'Project', todoFileId: 1, categoryId: 10),
            Todo(id: 101, name: 'Review', todoFileId: 1, categoryId: 10, parentTodoId: 100),
          ],
          20: const [
            Todo(id: 200, name: 'Archive', todoFileId: 2, categoryId: 20),
            Todo(id: 201, name: 'Review', todoFileId: 2, categoryId: 20, parentTodoId: 200),
          ],
        }),
        categories: categories,
        todoFiles: todoFiles,
      );
      final service = NotesMergeService(
        todoFiles: todoFiles,
        categories: categories,
        todos: todos,
        query: const NotesQueryService(),
      );

      await todoFiles.load();
      await categories.loadCategoriesForFiles(const [1, 2]);
      await todos.loadTodos(10);
      await todos.loadTodos(20);

      await service.mergeDuplicateLists(preferredFileId: 1);

      final mergedTodos = todos.todosByCategory.value[10]!;
      expect(mergedTodos.where((todo) => todo.name == 'Review').length, 2);
      expect(
        mergedTodos.where((todo) => todo.name == 'Review').map((todo) => todo.parentTodoId).toSet(),
        {100, 200},
      );
    });
  });
}

class _StubDatabaseManager extends Fake implements SupaDatabaseManager {}

class _FakeTodoFileRepository extends TodoFileRepository {
  _FakeTodoFileRepository(List<TodoFile> files)
      : _files = List<TodoFile>.from(files),
        super(_StubDatabaseManager());

  final List<TodoFile> _files;

  @override
  Future<List<TodoFile>> getAll() async => List<TodoFile>.from(_files);

  @override
  Future<TodoFile?> add(String name) async {
    final nextId = (_files.map((file) => file.id ?? 0).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
    final created = TodoFile(id: nextId, name: name);
    _files.add(created);
    return created;
  }

  @override
  Future<TodoFile?> update(TodoFile file) async {
    final index = _files.indexWhere((item) => item.id == file.id);
    if (index == -1) return null;
    _files[index] = file;
    return file;
  }

  @override
  Future<bool> touchLastUpdated(int id, DateTime timestamp) async {
    final index = _files.indexWhere((item) => item.id == id);
    if (index == -1) return false;
    _files[index] = _files[index].copyWith(lastUpdated: timestamp);
    return true;
  }

  @override
  Future<void> delete(int id) async {
    _files.removeWhere((file) => file.id == id);
  }
}

class _FakeCategoryRepository extends CategoryRepository {
  _FakeCategoryRepository(Map<int, List<Category>> categoriesByFile)
      : _categoriesByFile = {
          for (final entry in categoriesByFile.entries) entry.key: List<Category>.from(entry.value),
        },
        super(_StubDatabaseManager());

  final Map<int, List<Category>> _categoriesByFile;

  @override
  Future<List<Category>> getByTodoFile(int todoFileId) async {
    return List<Category>.from(_categoriesByFile[todoFileId] ?? const <Category>[]);
  }

  @override
  Future<Category?> add(Category category, int todoFileId) async {
    final nextId = _categoriesByFile.values
            .expand((items) => items)
            .map((item) => item.id ?? 0)
            .fold<int>(0, (a, b) => a > b ? a : b) +
        1;
    final created = category.copyWith(id: nextId, todoFileId: todoFileId);
    _categoriesByFile.putIfAbsent(todoFileId, () => <Category>[]).add(created);
    return created;
  }

  @override
  Future<Category?> update(Category category, int todoFileId) async {
    for (final categories in _categoriesByFile.values) {
      categories.removeWhere((item) => item.id == category.id);
    }
    _categoriesByFile.putIfAbsent(todoFileId, () => <Category>[]).add(category);
    return category;
  }

  @override
  Future<bool> touchLastUpdated(int id, DateTime timestamp) async {
    for (final categories in _categoriesByFile.values) {
      final index = categories.indexWhere((item) => item.id == id);
      if (index != -1) {
        categories[index] = categories[index].copyWith(lastUpdated: timestamp);
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> delete(int id) async {
    for (final categories in _categoriesByFile.values) {
      categories.removeWhere((item) => item.id == id);
    }
  }
}

class _FakeTodoRepository extends TodoRepository {
  _FakeTodoRepository(Map<int, List<Todo>> todosByCategory)
      : _todosByCategory = {
          for (final entry in todosByCategory.entries) entry.key: List<Todo>.from(entry.value),
        },
        super(_StubDatabaseManager());

  final Map<int, List<Todo>> _todosByCategory;

  @override
  Future<List<Todo>> getByCategory(int categoryId) async {
    return List<Todo>.from(_todosByCategory[categoryId] ?? const <Todo>[]);
  }

  @override
  Future<Todo?> add(Todo todo, int todoFileId, int categoryId) async {
    final nextId = _todosByCategory.values
            .expand((items) => items)
            .map((item) => item.id ?? 0)
            .fold<int>(0, (a, b) => a > b ? a : b) +
        1;
    final created = todo.copyWith(id: nextId, todoFileId: todoFileId, categoryId: categoryId);
    _todosByCategory.putIfAbsent(categoryId, () => <Todo>[]).add(created);
    return created;
  }

  @override
  Future<Todo?> update(Todo todo, int todoFileId, int categoryId) async {
    for (final todos in _todosByCategory.values) {
      todos.removeWhere((item) => item.id == todo.id);
    }
    _todosByCategory.putIfAbsent(categoryId, () => <Todo>[]).add(todo);
    return todo;
  }

  @override
  Future<bool> touchLastUpdated(int id, DateTime timestamp) async {
    for (final todos in _todosByCategory.values) {
      final index = todos.indexWhere((item) => item.id == id);
      if (index != -1) {
        todos[index] = todos[index].copyWith(lastUpdated: timestamp);
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> delete(int id) async {
    for (final todos in _todosByCategory.values) {
      todos.removeWhere((item) => item.id == id);
    }
  }
}
