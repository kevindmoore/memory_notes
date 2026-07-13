import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/search/application/search_store.dart';
import 'package:memory_notes/features/search/models/search_result_item.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  group('SearchStore', () {
    test('buildResults only searches open files when open file ids are provided', () {
      final todoFiles = TodoFileController(_StubTodoFileRepository());
      final categories = CategoryController(_StubCategoryRepository());
      final todos = TodoController(_StubTodoRepository());
      final store = SearchStore(
        todoFiles: todoFiles,
        categories: categories,
        todos: todos,
        query: const NotesQueryService(),
      );

      todoFiles.todoFiles.value = const [
        TodoFile(id: 1, name: 'Open Project'),
        TodoFile(id: 2, name: 'Closed Project'),
      ];
      categories.categories.value = const [
        Category(id: 10, name: 'Searchable Open Category', todoFileId: 1),
        Category(id: 20, name: 'Searchable Closed Category', todoFileId: 2),
      ];
      todos.todosByCategory.value = const {
        10: [
          Todo(id: 100, name: 'Searchable Open Task', todoFileId: 1, categoryId: 10),
        ],
        20: [
          Todo(id: 200, name: 'Searchable Closed Task', todoFileId: 2, categoryId: 20),
        ],
      };

      final results = store.buildResults('searchable', openFileIds: const [1]);

      expect(
        results.whereType<SearchCategoryResultItem>().map((item) => item.category.id),
        [10],
      );
      expect(
        results.whereType<SearchTodoResultItem>().map((item) => item.todo.id),
        [100],
      );
    });

    test('preload only loads todos for open file categories', () async {
      final todoRepository = _FakeTodoRepository(const {
        10: [Todo(id: 100, name: 'Open Task', todoFileId: 1, categoryId: 10)],
        20: [Todo(id: 200, name: 'Closed Task', todoFileId: 2, categoryId: 20)],
      });
      final todoFiles = TodoFileController(
        _FakeTodoFileRepository(
          const [
            TodoFile(id: 1, name: 'Open Project'),
            TodoFile(id: 2, name: 'Closed Project'),
          ],
        ),
      );
      final categories = CategoryController(
        _FakeCategoryRepository(
          const {
            1: [Category(id: 10, name: 'Open Category', todoFileId: 1)],
          },
        ),
      );
      final todos = TodoController(todoRepository);
      final store = SearchStore(
        todoFiles: todoFiles,
        categories: categories,
        todos: todos,
        query: const NotesQueryService(),
      );
      categories.categories.value = const [
        Category(id: 20, name: 'Closed Category', todoFileId: 2),
      ];

      await store.preload(openFileIds: const [1]);

      expect(todoRepository.requestedCategoryIds, [10]);
    });
  });
}

class _StubDatabaseManager extends Fake implements SupaDatabaseManager {}

class _StubTodoFileRepository extends TodoFileRepository {
  _StubTodoFileRepository() : super(_StubDatabaseManager());
}

class _StubCategoryRepository extends CategoryRepository {
  _StubCategoryRepository() : super(_StubDatabaseManager());
}

class _StubTodoRepository extends TodoRepository {
  _StubTodoRepository() : super(_StubDatabaseManager());
}

class _FakeTodoFileRepository extends TodoFileRepository {
  _FakeTodoFileRepository(this.files) : super(_StubDatabaseManager());

  final List<TodoFile> files;

  @override
  Future<List<TodoFile>> getAll() async => files;
}

class _FakeCategoryRepository extends CategoryRepository {
  _FakeCategoryRepository(this.categoriesByFile) : super(_StubDatabaseManager());

  final Map<int, List<Category>> categoriesByFile;

  @override
  Future<List<Category>> getByTodoFile(int todoFileId) async =>
      categoriesByFile[todoFileId] ?? const <Category>[];
}

class _FakeTodoRepository extends TodoRepository {
  _FakeTodoRepository(this.todosByCategory) : super(_StubDatabaseManager());

  final Map<int, List<Todo>> todosByCategory;
  final requestedCategoryIds = <int>[];

  @override
  Future<List<Todo>> getByCategory(int categoryId) async {
    requestedCategoryIds.add(categoryId);
    return todosByCategory[categoryId] ?? const <Todo>[];
  }
}
