import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_sort_order.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';

void main() {
  group('NotesQueryService', () {
    const service = NotesQueryService();

    test('normalizeFileIds keeps valid ids in order and removes duplicates', () {
      final files = [
        const TodoFile(name: 'One', id: 1),
        const TodoFile(name: 'Two', id: 2),
        const TodoFile(name: 'Three', id: 3),
      ];

      final result = service.normalizeFileIds([2, 99, 2, 1, 3, 1], files);

      expect(result, [2, 1, 3]);
    });

    test('normalizeName trims casing and repeated whitespace', () {
      expect(service.normalizeName('  Work   Notes  '), 'work notes');
    });

    test('findFileByName matches case-insensitively', () {
      final files = [
        const TodoFile(name: 'Work Notes', id: 1),
        const TodoFile(name: 'Personal', id: 2),
      ];

      final match = service.findFileByName(files, '  work   notes ');

      expect(match?.id, 1);
    });

    test('sortFiles prefers explicit open file order ahead of date sorting', () {
      final files = [
        TodoFile(
          name: 'Older',
          id: 1,
          lastUpdated: DateTime(2024, 1, 1),
        ),
        TodoFile(
          name: 'Newest',
          id: 2,
          lastUpdated: DateTime(2024, 5, 1),
        ),
        TodoFile(
          name: 'Middle',
          id: 3,
          lastUpdated: DateTime(2024, 3, 1),
        ),
      ];

      final result = service.sortFiles(
        files,
        sortOrder: NotesSortOrder.lastUpdated,
        preferredFileOrder: const [3, 1],
      );

      expect(result.map((file) => file.id).toList(), [3, 1, 2]);
    });

    test('sortFiles lastUpdated falls back to createdAt when lastUpdated is missing', () {
      final files = [
        TodoFile(
          name: 'Older',
          id: 1,
          createdAt: DateTime(2024, 1, 1),
        ),
        TodoFile(
          name: 'Newer',
          id: 2,
          createdAt: DateTime(2024, 5, 1),
        ),
      ];

      final result = service.sortFiles(
        files,
        sortOrder: NotesSortOrder.lastUpdated,
      );

      expect(result.map((file) => file.id).toList(), [2, 1]);
    });

    test('sortCategories newest falls back to createdAt when lastUpdated is missing', () {
      final older = Category(
        id: 1,
        name: 'Older',
        todoFileId: 100,
        createdAt: DateTime(2024, 1, 1),
      );
      final newer = Category(
        id: 2,
        name: 'Newer',
        todoFileId: 100,
        createdAt: DateTime(2024, 5, 1),
      );

      final result = service.sortCategories(
        [older, newer],
        sortOrder: CategorySortOrder.newest,
      );

      expect(result.map((category) => category.id).toList(), [2, 1]);
    });

    test('buildAncestorTodoIds and breadcrumb reflect nested todo hierarchy', () {
      const root = Todo(
        id: 10,
        name: 'Root',
        todoFileId: 1,
        categoryId: 100,
      );
      const child = Todo(
        id: 11,
        name: 'Child',
        todoFileId: 1,
        categoryId: 100,
        parentTodoId: 10,
      );
      const leaf = Todo(
        id: 12,
        name: 'Leaf',
        todoFileId: 1,
        categoryId: 100,
        parentTodoId: 11,
      );
      const category = Category(id: 100, name: 'Inbox', todoFileId: 1);
      const file = TodoFile(id: 1, name: 'Work');

      final ancestors = service.buildAncestorTodoIds(leaf, const [root, child, leaf]);
      final breadcrumb = service.buildTodoBreadcrumb(
        todo: leaf,
        allTodos: const [root, child, leaf],
        category: category,
        file: file,
      );

      expect(ancestors, [10, 11]);
      expect(breadcrumb, 'Root > Child > Inbox · Work');
    });

    test('sortTodos newest orders by lastUpdated', () {
      final older = Todo(
        id: 1,
        name: 'Older',
        categoryId: 100,
        lastUpdated: DateTime(2024, 1, 1),
      );
      final newer = Todo(
        id: 2,
        name: 'Newer',
        categoryId: 100,
        lastUpdated: DateTime(2024, 6, 1),
      );

      final result = service.sortTodos(
        [older, newer],
        sortOrder: TodoSortOrder.newest,
      );

      expect(result.map((t) => t.id).toList(), [2, 1]);
    });

    test('sortTodos newest falls back to createdAt when lastUpdated is missing', () {
      final older = Todo(
        id: 1,
        name: 'Older',
        categoryId: 100,
        createdAt: DateTime(2024, 1, 1),
      );
      final newer = Todo(
        id: 2,
        name: 'Newer',
        categoryId: 100,
        createdAt: DateTime(2024, 5, 1),
      );

      final result = service.sortTodos(
        [older, newer],
        sortOrder: TodoSortOrder.newest,
      );

      expect(result.map((todo) => todo.id).toList(), [2, 1]);
    });

    test('sortTodos nameAZ orders alphabetically', () {
      const b = Todo(id: 1, name: 'Beta', categoryId: 100);
      const a = Todo(id: 2, name: 'Alpha', categoryId: 100);

      final result = service.sortTodos(
        [b, a],
        sortOrder: TodoSortOrder.nameAZ,
      );

      expect(result.map((t) => t.name).toList(), ['Alpha', 'Beta']);
    });

    test('topLevelTodoCount counts only todos without a parent', () {
      const topA = Todo(id: 1, name: 'A', categoryId: 100);
      const topB = Todo(id: 2, name: 'B', categoryId: 100);
      const child = Todo(id: 3, name: 'Child', categoryId: 100, parentTodoId: 1);

      final count = service.topLevelTodoCount({
        100: const [topA, topB, child],
      }, 100);

      expect(count, 2);
    });
  });
}
