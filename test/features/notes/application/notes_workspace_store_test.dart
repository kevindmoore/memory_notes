import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/notes/models/notes_sort_order.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  group('NotesWorkspaceStore', () {
    test('initialize restores current files from device state and selects the first restored file',
        () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
        const TodoFile(id: 2, name: 'Beta'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
        2: [const Category(id: 20, name: 'Ideas', todoFileId: 2)],
      });
      final todoRepository = _FakeTodoRepository(const {});
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository()
        ..workspaceState = const PersistedWorkspaceState(openFileIds: [2, 999, 1]);

      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.initialize();

      expect(store.workspace.openFileIds.value, [2, 1]);
      expect(store.workspace.selectedFileId, 2);
      expect(store.categories.categories.value.map((item) => item.id).toList(), [10, 20]);
    });

    test('initialize loads the restored category todos so the saved task stays selected', () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
      });
      final todoRepository = _FakeTodoRepository({
        10: const [
          Todo(id: 100, name: 'Root', categoryId: 10),
          Todo(id: 101, name: 'Child', categoryId: 10, parentTodoId: 100),
        ],
      });
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository()
        ..workspaceState = const PersistedWorkspaceState(
          openFileIds: [1],
          selectedFileId: 1,
          selectionsByFile: {
            1: PersistedWorkspaceSelection(
              categoryId: 10,
              todoId: 101,
              todoPath: [100, 101],
            ),
          },
        );

      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.initialize();

      final viewState = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);
      expect(viewState.selectedCategory?.id, 10);
      expect(viewState.selectedTodo?.id, 101);
      expect(viewState.selectedTodoPath, [100, 101]);
    });

    test('initialize does not replace unrestorable saved files with a single fallback file',
        () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository()
        ..workspaceState = const PersistedWorkspaceState(openFileIds: [99, 100]);
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.initialize();

      expect(store.workspace.openFileIds.value, isEmpty);
      expect(store.workspace.selectedFileId, isNull);
      expect(deviceWorkspaceState.workspaceState.openFileIds, [99, 100]);
      expect(deviceWorkspaceState.saveWorkspaceStateCalls, 0);
    });

    test('loadTodos backs off after a failed read', () async {
      final todoRepository = _FakeTodoRepository({
        20: const [Todo(id: 200, name: 'Two', categoryId: 20)],
      });
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository(const []),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: todoRepository,
      );

      todoRepository.throwOnNextGetByCategory = StateError('network blip');

      final firstLoaded = await store.todos.loadTodos(10);
      final secondLoaded = await store.todos.loadTodos(20);

      expect(firstLoaded, isFalse);
      expect(secondLoaded, isFalse);
      expect(todoRepository.getByCategoryCalls, 1);
      expect(store.todos.getTodosForCategory(20), isEmpty);
    });

    test('persistCurrentFiles saves the normalized open-file ids to device state only', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      store.workspace.setOpenFileIds([2, 999, 1, 2]);

      await store.persistCurrentFiles();

      expect(deviceWorkspaceState.workspaceState.openFileIds, [2, 1]);
    });

    test('persistCurrentFiles skips duplicate saves when the workspace state is unchanged',
        () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      store.workspace.setOpenFileIds([2, 1]);

      await store.persistCurrentFiles();
      await store.persistCurrentFiles();

      expect(deviceWorkspaceState.saveWorkspaceStateCalls, 1);
    });

    test('persistCurrentFiles saves per-list desktop scroll offsets', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      store.workspace.setOpenFileIds([1, 2]);
      await store.saveDesktopScrollOffset(fileId: 2, offset: 512.25);

      expect(deviceWorkspaceState.workspaceState.selectionsByFile[2]?.desktopScrollOffset, 512.25);
    });

    test('selectFile restores the saved category and todo path when returning to a list', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
          2: [const Category(id: 20, name: 'Ideas', todoFileId: 2)],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [
            Todo(id: 100, name: 'Root', categoryId: 10),
            Todo(id: 101, name: 'Child', categoryId: 10, parentTodoId: 100),
          ],
          20: const [
            Todo(id: 200, name: 'Other', categoryId: 20),
          ],
        }),
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles([1, 2]);
      await store.todos.loadTodos(10);
      await store.todos.loadTodos(20);

      await store.selectCategory(
        file: const TodoFile(id: 1, name: 'Alpha'),
        category: const Category(id: 10, name: 'Inbox', todoFileId: 1),
      );
      store.selectTodo(
        fileId: 1,
        categoryId: 10,
        todoPath: const [100, 101],
      );

      await store.selectFile(const TodoFile(id: 2, name: 'Beta'));
      await store.selectFile(const TodoFile(id: 1, name: 'Alpha'));

      expect(store.workspace.selectedFileId, 1);
      expect(store.workspace.selectedCategoryId, 10);
      expect(store.workspace.selectedTodoId, 101);
      expect(store.workspace.selectedTodoPath, [100, 101]);
    });

    test('selectFile loads todos for every category in the selected file', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
            const Category(id: 11, name: 'Later', todoFileId: 1),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [Todo(id: 100, name: 'One', categoryId: 10)],
          11: const [
            Todo(id: 110, name: 'Two', categoryId: 11),
            Todo(id: 111, name: 'Three', categoryId: 11),
          ],
        }),
      );

      await store.todoFiles.load();
      await store.selectFile(const TodoFile(id: 1, name: 'Alpha'));

      expect(store.todos.getTodosForCategory(10).map((todo) => todo.id).toList(), [100]);
      expect(store.todos.getTodosForCategory(11).map((todo) => todo.id).toList(), [110, 111]);
    });

    test('initialize restores saved desktop scroll offsets', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository()
        ..workspaceState = const PersistedWorkspaceState(
          openFileIds: [1],
          selectedFileId: 1,
          selectionsByFile: {
            1: PersistedWorkspaceSelection(
              categoryId: 10,
              desktopScrollOffset: 320,
            ),
          },
        );
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
        }),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.initialize();

      expect(store.desktopScrollOffsetForFile(1), 320);
    });

    test('closeFile falls back to the next open file and persists', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
          const TodoFile(id: 3, name: 'Gamma'),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
      );

      await store.todoFiles.load();
      store.workspace.setOpenFileIds([2, 3]);
      store.workspace.selectFile(2);

      await store.closeFile(const TodoFile(id: 2, name: 'Beta'));

      expect(store.workspace.openFileIds.value, [3]);
      expect(store.workspace.selectedFileId, 3);
      expect(store.workspace.openFileIds.value, [3]);
    });

    test('closeFile reloads the next open file categories when the selected file closes', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
          2: [const Category(id: 20, name: 'Ideas', todoFileId: 2)],
        }),
        todoRepository: _FakeTodoRepository({
          20: const [Todo(id: 200, name: 'Two', categoryId: 20)],
        }),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      await store.openFile(const TodoFile(id: 1, name: 'Alpha'));
      await store.openFile(const TodoFile(id: 2, name: 'Beta'));

      await store.closeFile(const TodoFile(id: 2, name: 'Beta'));

      final viewState = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);
      expect(store.workspace.openFileIds.value, [1]);
      expect(store.workspace.selectedFileId, 1);
      expect(viewState.selectedCategory?.id, 10);
      expect(viewState.categories.map((item) => item.id).toList(), [10]);
      expect(deviceWorkspaceState.workspaceState.openFileIds, [1]);
    });

    test('closeFile keeps the workspace empty when the last open file closes', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [const Category(id: 10, name: 'Inbox', todoFileId: 1)],
        }),
        todoRepository: _FakeTodoRepository(const {}),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      await store.openFile(const TodoFile(id: 1, name: 'Alpha'));

      await store.closeFile(const TodoFile(id: 1, name: 'Alpha'));

      final viewState = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);
      expect(store.workspace.openFileIds.value, isEmpty);
      expect(store.workspace.selectedFileId, isNull);
      expect(viewState.selectedFile, isNull);
      expect(viewState.categories, isEmpty);
      expect(deviceWorkspaceState.workspaceState.openFileIds, isEmpty);
    });

    test('buildViewState separates open files from available files', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
          const TodoFile(id: 3, name: 'Gamma'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          2: [const Category(id: 20, name: 'Ideas', todoFileId: 2)],
        }),
        todoRepository: _FakeTodoRepository(const {}),
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles([2]);
      store.workspace.setOpenFileIds([2]);
      store.workspace.selectFile(2);

      final viewState = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);

      expect(viewState.openFileItems.map((item) => item.file.id).toList(), [2]);
      expect(viewState.fileItems.map((item) => item.file.id).toSet(), {1, 2, 3});
      expect(viewState.selectedFile?.id, 2);
      expect(viewState.categories.map((item) => item.id).toList(), [20]);
    });

    test('buildViewState keeps open files ordered by the desktop open order', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          TodoFile(
            id: 1,
            name: 'Alpha',
            lastUpdated: DateTime(2026, 3, 20),
          ),
          TodoFile(
            id: 2,
            name: 'Beta',
            lastUpdated: DateTime(2026, 3, 10),
          ),
        ]),
        categoryRepository: _FakeCategoryRepository(const {}),
        todoRepository: _FakeTodoRepository(const {}),
      );

      await store.todoFiles.load();
      store.workspace.setOpenFileIds([2, 1]);

      final viewState = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);

      expect(viewState.openFileItems.map((item) => item.file.id).toList(), [2, 1]);
      expect(viewState.fileItems.map((item) => item.file.id).toList(), [1, 2]);
    });

    test('saveTodoNotes updates parent todo, category, and file timestamps', () async {
      final originalFileTimestamp = DateTime(2026, 3, 20, 9);
      final originalCategoryTimestamp = DateTime(2026, 3, 20, 10);
      final originalParentTimestamp = DateTime(2026, 3, 20, 11);
      final originalChildTimestamp = DateTime(2026, 3, 20, 12);
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          TodoFile(id: 1, name: 'Alpha', lastUpdated: originalFileTimestamp),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            Category(
              id: 10,
              name: 'Inbox',
              todoFileId: 1,
              lastUpdated: originalCategoryTimestamp,
            ),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: [
            Todo(
              id: 100,
              name: 'Parent',
              todoFileId: 1,
              categoryId: 10,
              lastUpdated: originalParentTimestamp,
            ),
            Todo(
              id: 101,
              name: 'Child',
              todoFileId: 1,
              categoryId: 10,
              parentTodoId: 100,
              notes: 'Old note',
              lastUpdated: originalChildTimestamp,
            ),
          ],
        }),
      );

      await store.todoFiles.load();
      await store.categories.loadCategories(1);
      await store.todos.loadTodos(10);

      final childBefore = store.todos.getTodosForCategory(10).where((todo) => todo.id == 101).first;
      final parentBefore =
          store.todos.getTodosForCategory(10).where((todo) => todo.id == 100).first;

      await store.saveTodoNotes(childBefore, 'Updated note');

      final updatedChild =
          store.todos.getTodosForCategory(10).where((todo) => todo.id == 101).first;
      final updatedParent =
          store.todos.getTodosForCategory(10).where((todo) => todo.id == 100).first;
      final updatedCategory =
          store.categories.categories.value.where((category) => category.id == 10).first;
      final updatedFile = store.todoFiles.todoFiles.value.where((file) => file.id == 1).first;

      expect(updatedChild.notes, 'Updated note');
      expect(updatedChild.lastUpdated, isNotNull);
      expect(updatedChild.lastUpdated!.isAfter(originalChildTimestamp), isTrue);
      expect(updatedParent.lastUpdated, isNotNull);
      expect(updatedParent.lastUpdated!.isAfter(parentBefore.lastUpdated!), isTrue);
      expect(updatedCategory.lastUpdated, isNotNull);
      expect(updatedCategory.lastUpdated!.isAfter(originalCategoryTimestamp), isTrue);
      expect(updatedFile.lastUpdated, isNotNull);
      expect(updatedFile.lastUpdated!.isAfter(originalFileTimestamp), isTrue);
    });

    test('saveTodoNotes skips timestamp updates when the notes text is unchanged', () async {
      final originalFileTimestamp = DateTime(2026, 3, 20, 9);
      final originalCategoryTimestamp = DateTime(2026, 3, 20, 10);
      final originalTodoTimestamp = DateTime(2026, 3, 20, 11);
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          TodoFile(id: 1, name: 'Alpha', lastUpdated: originalFileTimestamp),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            Category(
              id: 10,
              name: 'Inbox',
              todoFileId: 1,
              lastUpdated: originalCategoryTimestamp,
            ),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: [
            Todo(
              id: 101,
              name: 'Child',
              todoFileId: 1,
              categoryId: 10,
              notes: 'Same note',
              lastUpdated: originalTodoTimestamp,
            ),
          ],
        }),
      );

      await store.todoFiles.load();
      await store.categories.loadCategories(1);
      await store.todos.loadTodos(10);

      final todoBefore = store.todos.getTodosForCategory(10).single;

      await store.saveTodoNotes(todoBefore, 'Same note');

      final todoAfter = store.todos.getTodosForCategory(10).single;
      final categoryAfter = store.categories.categories.value.single;
      final fileAfter = store.todoFiles.todoFiles.value.single;

      expect(todoAfter.lastUpdated, originalTodoTimestamp);
      expect(categoryAfter.lastUpdated, originalCategoryTimestamp);
      expect(fileAfter.lastUpdated, originalFileTimestamp);
    });

    test('addTodo updates file ordering by last updated', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          TodoFile(id: 1, name: 'Alpha', lastUpdated: DateTime(2026, 3, 20, 9)),
          TodoFile(id: 2, name: 'Beta', lastUpdated: DateTime(2026, 3, 20, 10)),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
          2: [
            const Category(id: 20, name: 'Ideas', todoFileId: 2),
          ],
        }),
        todoRepository: _FakeTodoRepository(const {}),
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles([1, 2]);

      final before = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);
      expect(before.fileItems.map((item) => item.file.id).toList(), [2, 1]);

      await store.addTodo(
        fileId: 1,
        categoryId: 10,
        text: 'New task',
      );

      final after = store.buildViewState(sortOrder: NotesSortOrder.lastUpdated);
      expect(after.fileItems.map((item) => item.file.id).toList(), [1, 2]);
    });

    test('addTodo selects the full path for a new child todo', () async {
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [
            Todo(id: 100, name: 'Parent', todoFileId: 1, categoryId: 10),
          ],
        }),
      );

      await store.todoFiles.load();
      await store.categories.loadCategories(1);
      await store.todos.loadTodos(10);

      final created = await store.addTodo(
        fileId: 1,
        categoryId: 10,
        text: 'Child',
        parentTodoId: 100,
      );

      expect(created?.parentTodoId, 100);
      expect(store.workspace.selectedTodoId, created?.id);
      expect(store.workspace.selectedTodoPath, [100, created!.id!]);
    });

    test('deleteTodo selects the parent when deleting the selected child todo', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [
            Todo(id: 100, name: 'Parent', todoFileId: 1, categoryId: 10),
            Todo(id: 101, name: 'Child', todoFileId: 1, categoryId: 10, parentTodoId: 100),
          ],
        }),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      await store.categories.loadCategories(1);
      await store.todos.loadTodos(10);
      store.workspace.selectTodo(
        fileId: 1,
        categoryId: 10,
        todoId: 101,
        todoPath: const [100, 101],
      );

      await store.deleteTodo(
        const Todo(id: 101, name: 'Child', todoFileId: 1, categoryId: 10, parentTodoId: 100),
      );

      expect(store.workspace.selectedTodoId, 100);
      expect(store.workspace.selectedTodoPath, [100]);
      expect(store.todos.getTodosForCategory(10).map((todo) => todo.id).toList(), [100]);
      expect(deviceWorkspaceState.workspaceState.selectionsByFile[1]?.todoId, 100);
      expect(deviceWorkspaceState.workspaceState.selectionsByFile[1]?.todoPath, [100]);
    });

    test('toggleTodo clears the selected task for the current category', () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository();
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [
            Todo(id: 100, name: 'First', todoFileId: 1, categoryId: 10),
            Todo(id: 101, name: 'Second', todoFileId: 1, categoryId: 10),
          ],
        }),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      await store.categories.loadCategories(1);
      await store.todos.loadTodos(10);
      store.workspace.selectTodo(
        fileId: 1,
        categoryId: 10,
        todoId: 100,
        todoPath: const [100],
      );

      await store.toggleTodo(
        const Todo(id: 101, name: 'Second', todoFileId: 1, categoryId: 10),
      );

      expect(store.workspace.selectedFileId, 1);
      expect(store.workspace.selectedCategoryId, 10);
      expect(store.workspace.selectedTodoId, isNull);
      expect(store.workspace.selectedTodoPath, isEmpty);
      expect(store.todos.getTodosForCategory(10).singleWhere((todo) => todo.id == 101).done, true);
      expect(deviceWorkspaceState.workspaceState.selectionsByFile[1]?.todoId, isNull);
      expect(deviceWorkspaceState.workspaceState.selectionsByFile[1]?.todoPath, isEmpty);
    });

    test('reloadFile refreshes categories and todos for that list from the repository', () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [
          const Category(id: 10, name: 'Inbox', todoFileId: 1),
        ],
      });
      final todoRepository = _FakeTodoRepository({
        10: const [Todo(id: 100, name: 'Before', categoryId: 10)],
      });
      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
      );

      await store.todoFiles.load();
      await store.selectFile(const TodoFile(id: 1, name: 'Alpha'));

      categoryRepository._categoriesByFile[1] = [
        const Category(id: 10, name: 'Inbox', todoFileId: 1),
        const Category(id: 11, name: 'Later', todoFileId: 1),
      ];
      todoRepository._todosByCategory[10] = [
        const Todo(id: 100, name: 'After', categoryId: 10),
      ];
      todoRepository._todosByCategory[11] = [
        const Todo(id: 110, name: 'New Todo', categoryId: 11),
      ];

      await store.reloadFile(1);

      expect(
          store.categories.categories.value
              .where((item) => item.todoFileId == 1)
              .map((item) => item.id)
              .toSet(),
          {10, 11});
      expect(store.todos.getTodosForCategory(10).single.name, 'After');
      expect(store.todos.getTodosForCategory(11).single.name, 'New Todo');
    });

    test('reloadOpenFiles refreshes all currently open lists', () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
        const TodoFile(id: 2, name: 'Beta'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [
          const Category(id: 10, name: 'Inbox', todoFileId: 1),
        ],
        2: [
          const Category(id: 20, name: 'Ideas', todoFileId: 2),
        ],
      });
      final todoRepository = _FakeTodoRepository({
        10: const [Todo(id: 100, name: 'One', categoryId: 10)],
        20: const [Todo(id: 200, name: 'Two', categoryId: 20)],
      });
      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
      );

      await store.todoFiles.load();
      await store.openFile(const TodoFile(id: 1, name: 'Alpha'));
      await store.openFile(const TodoFile(id: 2, name: 'Beta'));

      todoRepository._todosByCategory[10] = [
        const Todo(id: 100, name: 'One Reloaded', categoryId: 10),
      ];
      todoRepository._todosByCategory[20] = [
        const Todo(id: 200, name: 'Two Reloaded', categoryId: 20),
      ];

      await store.reloadOpenFiles();

      expect(store.todos.getTodosForCategory(10).single.name, 'One Reloaded');
      expect(store.todos.getTodosForCategory(20).single.name, 'Two Reloaded');
    });

    test('reloadAllFiles refreshes closed-file categories and loaded todos', () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
        const TodoFile(id: 2, name: 'Beta'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [
          const Category(id: 10, name: 'Inbox', todoFileId: 1),
        ],
        2: [
          const Category(id: 20, name: 'Ideas', todoFileId: 2),
        ],
      });
      final todoRepository = _FakeTodoRepository({
        10: const [Todo(id: 100, name: 'One', categoryId: 10)],
        20: const [Todo(id: 200, name: 'Two', categoryId: 20)],
      });
      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles(const [1, 2]);
      await store.todos.loadTodos(20);

      categoryRepository._categoriesByFile[2] = [
        const Category(id: 20, name: 'Updated Ideas', todoFileId: 2),
      ];
      todoRepository._todosByCategory[20] = [
        const Todo(id: 200, name: 'Two Reloaded', categoryId: 20),
      ];

      await store.reloadAllFiles();

      expect(
        store.categories.categories.value
            .where((item) => item.todoFileId == 2)
            .map((item) => item.name)
            .toList(),
        ['Updated Ideas'],
      );
      expect(store.todos.getTodosForCategory(20).single.name, 'Two Reloaded');
    });

    test('reloadAllFiles preserves existing lists when a refresh returns an empty file set',
        () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
        const TodoFile(id: 2, name: 'Beta'),
      ]);
      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [Todo(id: 100, name: 'One', categoryId: 10)],
        }),
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles(const [1]);
      await store.todos.loadTodos(10);
      store.workspace.setOpenFileIds([1]);
      store.workspace.selectFile(1);

      fileRepository.returnEmptyOnNextGetAll = true;

      await store.reloadAllFiles();

      expect(store.todoFiles.todoFiles.value.map((file) => file.id).toList(), [1, 2]);
      expect(store.workspace.openFileIds.value, [1]);
      expect(store.workspace.selectedFileId, 1);
      expect(
        store.categories.categories.value.map((category) => category.id).toList(),
        [10],
      );
      expect(store.todos.getTodosForCategory(10).map((todo) => todo.id).toList(), [100]);
    });

    test('reloadAllFiles preserves existing data when refresh reads throw', () async {
      final fileRepository = _FakeTodoFileRepository([
        const TodoFile(id: 1, name: 'Alpha'),
      ]);
      final categoryRepository = _FakeCategoryRepository({
        1: [
          const Category(id: 10, name: 'Inbox', todoFileId: 1),
        ],
      });
      final todoRepository = _FakeTodoRepository({
        10: const [Todo(id: 100, name: 'One', categoryId: 10)],
      });
      final store = _buildStore(
        fileRepository: fileRepository,
        categoryRepository: categoryRepository,
        todoRepository: todoRepository,
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles(const [1]);
      await store.todos.loadTodos(10);
      store.workspace.setOpenFileIds([1]);
      store.workspace.selectFile(1);

      fileRepository.throwOnNextGetAll = StateError('network blip');
      categoryRepository.throwOnNextGetByTodoFile = StateError('network blip');
      todoRepository.throwOnNextGetByCategory = StateError('network blip');

      await store.reloadAllFiles();

      expect(store.todoFiles.todoFiles.value.map((file) => file.id).toList(), [1]);
      expect(store.categories.categories.value.map((category) => category.id).toList(), [10]);
      expect(store.todos.getTodosForCategory(10).map((todo) => todo.id).toList(), [100]);
    });

    test('reloadAllFiles keeps the current local open lists and selection during refresh',
        () async {
      final deviceWorkspaceState = _FakeDeviceWorkspaceStateRepository()
        ..workspaceState = const PersistedWorkspaceState(
          openFileIds: [2],
          selectedFileId: 2,
          selectionsByFile: {
            2: PersistedWorkspaceSelection(
              categoryId: 20,
              todoId: 200,
              todoPath: [200],
            ),
          },
        );
      final store = _buildStore(
        fileRepository: _FakeTodoFileRepository([
          const TodoFile(id: 1, name: 'Alpha'),
          const TodoFile(id: 2, name: 'Beta'),
        ]),
        categoryRepository: _FakeCategoryRepository({
          1: [
            const Category(id: 10, name: 'Inbox', todoFileId: 1),
          ],
          2: [
            const Category(id: 20, name: 'Ideas', todoFileId: 2),
          ],
        }),
        todoRepository: _FakeTodoRepository({
          10: const [Todo(id: 100, name: 'One', categoryId: 10)],
          20: const [Todo(id: 200, name: 'Two', categoryId: 20)],
        }),
        deviceWorkspaceState: deviceWorkspaceState,
      );

      await store.todoFiles.load();
      await store.categories.loadCategoriesForFiles(const [1, 2]);
      await store.todos.loadTodos(10);
      store.workspace.setOpenFileIds([1]);
      store.workspace.selectFile(1);

      await store.reloadAllFiles();

      expect(store.workspace.openFileIds.value, [1]);
      expect(store.workspace.selectedFileId, 1);
      expect(deviceWorkspaceState.workspaceState.openFileIds, [1]);
    });
  });
}

NotesWorkspaceStore _buildStore({
  required _FakeTodoFileRepository fileRepository,
  required _FakeCategoryRepository categoryRepository,
  required _FakeTodoRepository todoRepository,
  _FakeDeviceWorkspaceStateRepository? deviceWorkspaceState,
}) {
  final workspace = NotesWorkspaceController();
  final todoFiles = TodoFileController(fileRepository);
  final categories = CategoryController(
    categoryRepository,
    todoFiles: todoFiles,
  );
  final todos = TodoController(
    todoRepository,
    categories: categories,
    todoFiles: todoFiles,
  );
  return NotesWorkspaceStore(
    workspace: workspace,
    deviceWorkspaceState: deviceWorkspaceState ?? _FakeDeviceWorkspaceStateRepository(),
    query: const NotesQueryService(),
    todoFiles: todoFiles,
    categories: categories,
    todos: todos,
  );
}

class _StubDatabaseManager extends Fake implements SupaDatabaseManager {}

class _FakeTodoFileRepository extends TodoFileRepository {
  _FakeTodoFileRepository(List<TodoFile> files)
      : _files = List<TodoFile>.from(files),
        super(_StubDatabaseManager());

  final List<TodoFile> _files;
  bool returnEmptyOnNextGetAll = false;
  Object? throwOnNextGetAll;

  @override
  Future<List<TodoFile>> getAll() async {
    final error = throwOnNextGetAll;
    throwOnNextGetAll = null;
    if (error != null) {
      throw error;
    }
    if (returnEmptyOnNextGetAll) {
      returnEmptyOnNextGetAll = false;
      return const <TodoFile>[];
    }
    return List<TodoFile>.from(_files);
  }

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
  Object? throwOnNextGetByTodoFile;

  @override
  Future<List<Category>> getByTodoFile(int todoFileId) async {
    final error = throwOnNextGetByTodoFile;
    throwOnNextGetByTodoFile = null;
    if (error != null) {
      throw error;
    }
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
    final categories = _categoriesByFile[todoFileId];
    if (categories == null) return null;
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index == -1) return null;
    categories[index] = category;
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
  Object? throwOnNextGetByCategory;
  int getByCategoryCalls = 0;

  @override
  Future<List<Todo>> getByCategory(int categoryId) async {
    getByCategoryCalls++;
    final error = throwOnNextGetByCategory;
    throwOnNextGetByCategory = null;
    if (error != null) {
      throw error;
    }
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
    final todos = _todosByCategory[categoryId];
    if (todos == null) return null;
    final index = todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return null;
    todos[index] = todo;
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

class _FakeDeviceWorkspaceStateRepository extends DeviceWorkspaceStateRepository {
  _FakeDeviceWorkspaceStateRepository()
      : workspaceState = const PersistedWorkspaceState(),
        super(currentUserId: () => 'test-user');

  PersistedWorkspaceState workspaceState;
  int saveWorkspaceStateCalls = 0;

  @override
  Future<PersistedWorkspaceState> getWorkspaceState() async => PersistedWorkspaceState(
        openFileIds: List<int>.from(workspaceState.openFileIds),
        selectedFileId: workspaceState.selectedFileId,
        selectionsByFile:
            Map<int, PersistedWorkspaceSelection>.from(workspaceState.selectionsByFile),
      );

  @override
  Future<void> saveWorkspaceState({
    required List<int> openFileIds,
    required int? selectedFileId,
    required Map<int, PersistedWorkspaceSelection> selectionsByFile,
  }) async {
    saveWorkspaceStateCalls++;
    workspaceState = PersistedWorkspaceState(
      openFileIds: List<int>.from(openFileIds),
      selectedFileId: selectedFileId,
      selectionsByFile: Map<int, PersistedWorkspaceSelection>.from(selectionsByFile),
    );
  }
}
