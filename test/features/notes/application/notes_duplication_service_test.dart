import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_duplication_service.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  test('copyTodo copies a note and its descendants beneath the destination note', () async {
    final todoFiles = TodoFileController(_UnusedTodoFileRepository());
    final categories = CategoryController(_UnusedCategoryRepository());
    final todoRepository = _FakeTodoRepository({
      10: const [
        Todo(
          id: 100,
          name: 'Source',
          todoFileId: 1,
          categoryId: 10,
          notes: 'Source notes',
        ),
        Todo(
          id: 101,
          name: 'Child',
          todoFileId: 1,
          categoryId: 10,
          parentTodoId: 100,
        ),
      ],
      20: const [
        Todo(id: 200, name: 'Destination', todoFileId: 2, categoryId: 20),
      ],
    });
    final todos = TodoController(todoRepository);
    categories.loadedCategoryFileIds.add(1);
    todos.todosByCategory[10] = await todoRepository.getByCategory(10);
    todos.todosByCategory[20] = await todoRepository.getByCategory(20);
    final service = NotesDuplicationService(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: const NotesQueryService(),
    );

    final copied = await service.copyTodo(
      todo: todos.todosByCategory[10]!.first,
      targetFileId: 2,
      targetCategoryId: 20,
      targetParentTodoId: 200,
    );

    final destinationTodos = todos.todosByCategory[20]!;
    expect(destinationTodos.map((todo) => todo.name), ['Destination', 'Source', 'Child']);
    final copiedChild = destinationTodos.singleWhere((todo) => todo.name == 'Child');
    expect(copied?.name, 'Source');
    expect(copied?.notes, 'Source notes');
    expect(copied?.todoFileId, 2);
    expect(copied?.categoryId, 20);
    expect(copied?.parentTodoId, 200);
    expect(copiedChild.parentTodoId, copied?.id);

    final copiedAtCategoryRoot = await service.copyTodo(
      todo: todos.todosByCategory[10]!.first,
      targetFileId: 2,
      targetCategoryId: 20,
      targetParentTodoId: null,
    );

    expect(copiedAtCategoryRoot?.parentTodoId, isNull);
  });
}

class _StubDatabaseManager extends Fake implements SupaDatabaseManager {}

class _UnusedTodoFileRepository extends TodoFileRepository {
  _UnusedTodoFileRepository() : super(_StubDatabaseManager());
}

class _UnusedCategoryRepository extends CategoryRepository {
  _UnusedCategoryRepository() : super(_StubDatabaseManager());
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
    final nextId =
        _todosByCategory.values
            .expand((todos) => todos)
            .map((todo) => todo.id ?? 0)
            .fold<int>(0, (left, right) => left > right ? left : right) +
        1;
    final created = todo.copyWith(
      id: nextId,
      todoFileId: todoFileId,
      categoryId: categoryId,
    );
    _todosByCategory.putIfAbsent(categoryId, () => <Todo>[]).add(created);
    return created;
  }

  @override
  Future<bool> touchLastUpdated(int id, DateTime timestamp) async {
    return true;
  }
}
