import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/instant_notes/application/instant_notes_store.dart';
import 'package:memory_notes/features/instant_notes/presentation/instant_notes_screen.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  testWidgets('saving while listening clears the field after late speech completion', (
    tester,
  ) async {
    final instantNoteRepository = _FakeInstantNoteRepository();
    final speech = _FakeSpeechController();
    final todoFiles = TodoFileController(_FakeTodoFileRepository());
    final categories = CategoryController(_FakeCategoryRepository());
    final todos = TodoController(_FakeTodoRepository());
    final instantNotes = InstantNotesStore(instantNoteRepository, todos);

    await tester.pumpWidget(
      MaterialApp(
        home: InstantNotesScreen(
          instantNotes: instantNotes,
          todoFiles: todoFiles,
          categories: categories,
          speech: speech,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    speech.emitRecognizedText('unfinished note');
    await tester.pump();

    await tester.tap(find.text('Save Instant Note'));
    await tester.pump();
    speech.emitCompletion();
    await tester.pump();

    expect(instantNoteRepository.addedNotes, ['Unfinished note']);
    expect(find.widgetWithText(TextField, 'Unfinished note'), findsNothing);
    expect(find.widgetWithText(TextField, ''), findsOneWidget);
  });

  testWidgets('editing an instant note saves the updated text', (tester) async {
    final instantNoteRepository = _FakeInstantNoteRepository(
      notes: [
        InstantNote(
          id: 1,
          notes: 'First draft',
          createdAt: DateTime(2026),
        ),
      ],
    );
    final speech = _FakeSpeechController();
    final todoFiles = TodoFileController(_FakeTodoFileRepository());
    final categories = CategoryController(_FakeCategoryRepository());
    final todos = TodoController(_FakeTodoRepository());
    final instantNotes = InstantNotesStore(instantNoteRepository, todos);

    await tester.pumpWidget(
      MaterialApp(
        home: InstantNotesScreen(
          instantNotes: instantNotes,
          todoFiles: todoFiles,
          categories: categories,
          speech: speech,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.list_alt_rounded));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'First draft'), 'Updated note');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pump();

    expect(instantNoteRepository.updatedNotes, ['Updated note']);
    expect(find.widgetWithText(TextField, 'Updated note'), findsOneWidget);
  });

  testWidgets('move dialog mic fills the todo title', (tester) async {
    final instantNoteRepository = _FakeInstantNoteRepository(
      notes: [
        InstantNote(
          id: 1,
          notes: 'Call Alice about plans',
          createdAt: DateTime(2026),
        ),
      ],
    );
    final speech = _FakeSpeechController();
    final todoFiles = TodoFileController(
      _FakeTodoFileRepository(
        files: const [TodoFile(id: 1, name: 'Personal')],
      ),
    );
    final categories = CategoryController(
      _FakeCategoryRepository(
        categories: const [Category(id: 10, name: 'Today', todoFileId: 1)],
      ),
    );
    final todos = TodoController(_FakeTodoRepository());
    final instantNotes = InstantNotesStore(instantNoteRepository, todos);

    await tester.pumpWidget(
      MaterialApp(
        home: InstantNotesScreen(
          instantNotes: instantNotes,
          todoFiles: todoFiles,
          categories: categories,
          speech: speech,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.list_alt_rounded));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Move'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    speech.emitRecognizedText('call Alice');
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Call Alice'), findsOneWidget);
  });
}

class _FakeSpeechController extends SpeechController {
  final _recognizedTextController = StreamController<String>.broadcast();
  final _completionController = StreamController<void>.broadcast();
  final _statusController = StreamController<SpeechStatus>.broadcast();
  final _status = signal(SpeechStatus.idle);
  final _activeOwner = signal<Object?>(null);
  final _lastRecognizedText = signal('');
  final _errorMessage = signal<String?>(null);

  @override
  Signal<SpeechStatus> get status => _status;

  @override
  Signal<Object?> get activeOwner => _activeOwner;

  @override
  Signal<String> get lastRecognizedText => _lastRecognizedText;

  @override
  Signal<String?> get errorMessage => _errorMessage;

  @override
  Stream<String> get recognizedTextStream => _recognizedTextController.stream;

  @override
  Stream<void> get completionStream => _completionController.stream;

  @override
  Stream<SpeechStatus> get statusStream => _statusController.stream;

  @override
  bool get isListening => status.value == SpeechStatus.listening;

  @override
  Future<bool> startListening({Object? owner}) async {
    activeOwner.value = owner;
    status.value = SpeechStatus.listening;
    _statusController.add(SpeechStatus.listening);
    return true;
  }

  @override
  Future<void> stopListening() async {
    activeOwner.value = null;
    status.value = SpeechStatus.idle;
    _statusController.add(SpeechStatus.idle);
  }

  void emitRecognizedText(String text) {
    lastRecognizedText.value = text;
    _recognizedTextController.add(text);
  }

  void emitCompletion() {
    _completionController.add(null);
  }
}

class _FakeInstantNoteRepository extends InstantNoteRepository {
  _FakeInstantNoteRepository({List<InstantNote> notes = const []})
      : _notes = notes,
        super(_FakeDatabaseManager());

  final addedNotes = <String>[];
  final updatedNotes = <String>[];
  final List<InstantNote> _notes;

  @override
  Future<List<InstantNote>> getAll() async => _notes;

  @override
  Future<InstantNote?> add(String notes) async {
    addedNotes.add(notes);
    return InstantNote(id: addedNotes.length, notes: notes);
  }

  @override
  Future<InstantNote?> update(InstantNote instantNote) async {
    updatedNotes.add(instantNote.notes);
    return instantNote;
  }
}

class _FakeTodoFileRepository extends TodoFileRepository {
  _FakeTodoFileRepository({this.files = const []}) : super(_FakeDatabaseManager());

  final List<TodoFile> files;

  @override
  Future<List<TodoFile>> getAll() async => files;
}

class _FakeCategoryRepository extends CategoryRepository {
  _FakeCategoryRepository({this.categories = const []}) : super(_FakeDatabaseManager());

  final List<Category> categories;

  @override
  Future<List<Category>> getByTodoFile(int todoFileId) async =>
      categories.where((category) => category.todoFileId == todoFileId).toList(growable: false);
}

class _FakeTodoRepository extends TodoRepository {
  _FakeTodoRepository() : super(_FakeDatabaseManager());
}

class _FakeDatabaseManager extends Fake implements SupaDatabaseManager {}
