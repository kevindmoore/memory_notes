import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/search/application/search_store.dart';
import 'package:memory_notes/features/search/presentation/search_screen.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  testWidgets('waits for workspace restoration before searching open lists', (tester) async {
    final todoFiles = TodoFileController(
      _FakeTodoFileRepository(const [TodoFile(id: 1, name: 'Project')]),
    );
    final categories = CategoryController(
      _FakeCategoryRepository(const {
        1: [Category(id: 10, name: 'Category', todoFileId: 1)],
      }),
    );
    final todos = TodoController(
      _FakeTodoRepository(const {
        10: [Todo(id: 100, name: 'Needle task', todoFileId: 1, categoryId: 10)],
      }),
    );
    final search = SearchStore(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: const NotesQueryService(),
    );
    final notesWorkspace = _DelayedNotesWorkspaceStore();

    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          search: search,
          notesMobile: _FakeNotesMobileStore(),
          notesWorkspace: notesWorkspace,
          noteDetailActions: _FakeNoteDetailActions(),
          noteEditActions: _FakeNoteEditActions(),
          speech: _FakeSpeechController(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'needle');
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No results for "needle"'), findsNothing);

    notesWorkspace.completeInitialization(openFileIds: const [1]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Needle task', findRichText: true), findsOneWidget);
    expect(find.text('No results for "needle"'), findsNothing);
  });
}

class _DelayedNotesWorkspaceStore extends Fake implements NotesWorkspaceStore {
  final _initialization = Completer<void>();

  @override
  final workspace = NotesWorkspaceController();

  @override
  final query = const NotesQueryService();

  @override
  Future<void> initialize() => _initialization.future;

  void completeInitialization({required List<int> openFileIds}) {
    workspace.setOpenFileIds(openFileIds);
    _initialization.complete();
  }
}

class _FakeNotesMobileStore extends Fake implements NotesMobileStore {}

class _FakeNoteDetailActions extends Fake implements NoteDetailActions {}

class _FakeNoteEditActions extends Fake implements NoteEditActions {}

class _FakeSpeechController extends Fake implements SpeechController {
  @override
  Stream<SpeechStatus> get statusStream => const Stream.empty();
}

class _FakeDatabaseManager extends Fake implements SupaDatabaseManager {}

class _FakeTodoFileRepository extends TodoFileRepository {
  _FakeTodoFileRepository(this.files) : super(_FakeDatabaseManager());

  final List<TodoFile> files;

  @override
  Future<List<TodoFile>> getAll() async => files;
}

class _FakeCategoryRepository extends CategoryRepository {
  _FakeCategoryRepository(this.categoriesByFile) : super(_FakeDatabaseManager());

  final Map<int, List<Category>> categoriesByFile;

  @override
  Future<List<Category>> getByTodoFile(int todoFileId) async =>
      categoriesByFile[todoFileId] ?? const <Category>[];
}

class _FakeTodoRepository extends TodoRepository {
  _FakeTodoRepository(this.todosByCategory) : super(_FakeDatabaseManager());

  final Map<int, List<Todo>> todosByCategory;

  @override
  Future<List<Todo>> getByCategory(int categoryId) async =>
      todosByCategory[categoryId] ?? const <Todo>[];
}
