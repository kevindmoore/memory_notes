import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_selection.dart';

void main() {
  group('NotesWorkspaceController', () {
    test('selectFile opens the file and clears category/todo selection', () {
      final controller = NotesWorkspaceController();

      controller.selectCategory(fileId: 1, categoryId: 10, todoId: 100);
      controller.selectFile(2);

      expect(controller.selectedFileId, 2);
      expect(controller.selectedCategoryId, isNull);
      expect(controller.selectedTodoId, isNull);
      expect(controller.selectedTodoPath, isEmpty);
      expect(controller.openFileIds.value, contains(2));
    });

    test('markFileUsed moves an open file to the front of the MRU list', () {
      final controller = NotesWorkspaceController();

      controller.setOpenFileIds(const [1, 2, 3]);
      controller.markFileUsed(2);

      expect(controller.openFileIds.value, [2, 1, 3]);
    });

    test('syncWithData removes missing open files and clears deleted selection', () {
      final controller = NotesWorkspaceController();

      controller.setOpenFileIds(const [1, 2, 3]);
      controller.selectCategory(fileId: 2, categoryId: 20);

      controller.syncWithData(
        files: const [
          TodoFile(id: 1, name: 'One'),
          TodoFile(id: 3, name: 'Three'),
        ],
        categories: const [],
        todosByCategory: const {},
      );

      expect(controller.openFileIds.value, [1, 3]);
      expect(controller.selectedFileId, isNull);
      expect(controller.selectedCategoryId, isNull);
    });

    test('syncWithData trims invalid todo paths to the deepest valid node', () {
      final controller = NotesWorkspaceController();

      controller.selectTodo(
        fileId: 1,
        categoryId: 10,
        todoId: 102,
        todoPath: const [100, 101, 102],
      );

      controller.syncWithData(
        files: const [TodoFile(id: 1, name: 'One')],
        categories: const [Category(id: 10, name: 'Inbox', todoFileId: 1)],
        todosByCategory: const {
          10: [
            Todo(id: 100, name: 'Root', categoryId: 10, parentTodoId: null),
            Todo(id: 101, name: 'Child', categoryId: 10, parentTodoId: 100),
            Todo(id: 102, name: 'Wrong Parent', categoryId: 10, parentTodoId: 999),
          ],
        },
        loadedCategoryFileIds: const {1},
        loadedTodoCategoryIds: const {10},
      );

      expect(controller.selectedTodoId, 101);
      expect(controller.selectedTodoPath, [100, 101]);
    });

    test('syncWithData auto-selects the first file when none is selected', () {
      final controller = NotesWorkspaceController();

      controller.syncWithData(
        files: const [
          TodoFile(id: 7, name: 'Primary'),
          TodoFile(id: 8, name: 'Secondary'),
        ],
        categories: const [],
        todosByCategory: const {},
      );

      expect(controller.selectedFileId, 7);
      expect(controller.openFileIds.value, contains(7));
    });

    test('syncWithData auto-selects the first category for the selected file', () {
      final controller = NotesWorkspaceController();

      controller.selectFile(7);

      controller.syncWithData(
        files: const [
          TodoFile(id: 7, name: 'Primary'),
        ],
        categories: const [
          Category(id: 70, name: 'Inbox', todoFileId: 7),
          Category(id: 71, name: 'Ideas', todoFileId: 7),
        ],
        todosByCategory: const {},
        loadedCategoryFileIds: const {7},
      );

      expect(controller.selectedFileId, 7);
      expect(controller.selectedCategoryId, 70);
      expect(controller.openFileIds.value, contains(7));
    });

    test('selectFile restores the saved category and todo path for that file', () {
      final controller = NotesWorkspaceController();

      controller.restoreSavedSelections({
        1: const NotesWorkspaceSelection(
          fileId: 1,
          categoryId: 10,
          todoId: 101,
          todoPath: [100, 101],
        ),
      });

      controller.selectFile(1);

      expect(controller.selectedFileId, 1);
      expect(controller.selectedCategoryId, 10);
      expect(controller.selectedTodoId, 101);
      expect(controller.selectedTodoPath, [100, 101]);
    });

    test('saveDesktopScrollOffset stores and restores a per-file desktop offset', () {
      final controller = NotesWorkspaceController();

      controller.restoreDesktopScrollOffsets({1: 240.5});
      controller.saveDesktopScrollOffset(fileId: 2, offset: 480);

      expect(controller.desktopScrollOffsetForFile(1), 240.5);
      expect(controller.desktopScrollOffsetForFile(2), 480);
    });
  });
}
