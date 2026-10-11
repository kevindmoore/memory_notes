import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/presentation/dialogs/notes_dialogs.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';

void main() {
  testWidgets('task submission closes without waiting for speech or creation', (tester) async {
    final speech = _PendingStopSpeechController();
    final creation = Completer<void>();
    String? submittedText;
    var creationFinished = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              submittedText = await showNotesTextPromptDialog(
                context,
                title: 'New Task',
                hintText: 'Task name',
                confirmLabel: 'Create',
                speech: speech,
              );
              await creation.future;
              creationFinished = true;
            },
            child: const Text('Show dialog'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Call Alice');
    speech.activeOwner.value = Object();
    speech.status.value = SpeechStatus.listening;

    await tester.tap(find.text('Create'));
    expect(speech.stopRequested, isTrue);
    await tester.pumpAndSettle();

    expect(submittedText, 'Call Alice');
    expect(find.byType(AlertDialog), findsNothing);
    expect(speech.stopped.isCompleted, isFalse);
    expect(creationFinished, isFalse);

    speech.stopped.complete();
    creation.complete();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    speech.dispose();
  });

  testWidgets('open list dialog filters lists as the search query changes', (tester) async {
    int? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selectedValue = await showNotesSelectionDialog<int>(
                context,
                title: 'Open List',
                emptyMessage: 'All lists are already open.',
                searchHintText: 'Search lists...',
                items: const [
                  NotesSelectionDialogItem(value: 1, label: 'Alpha', subtitle: '2 categories'),
                  NotesSelectionDialogItem(value: 2, label: 'Beta', subtitle: '3 categories'),
                ],
              );
            },
            child: const Text('Show dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show dialog'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Search lists...'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ALP');
    await tester.pump();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();

    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsNothing);
    expect(find.text('No lists found for "missing"'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(selectedValue, 2);
  });

  testWidgets('open list dialog fits above an open keyboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetViewInsets();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showNotesSelectionDialog<int>(
              context,
              title: 'Open List',
              emptyMessage: 'All lists are already open.',
              searchHintText: 'Search lists...',
              items: List.generate(
                20,
                (index) => NotesSelectionDialogItem(value: index, label: 'List $index'),
              ),
            ),
            child: const Text('Show dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show dialog'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('copy note dialog drills into a list, category, and destination note', (
    tester,
  ) async {
    CopyNoteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selectedDestination = await showCopyNoteDestinationDialog(
                context,
                sourceTodo: const Todo(id: 100, name: 'Source'),
                files: [
                  TodoFile(
                    id: 1,
                    name: 'Personal',
                    lastUpdated: DateTime(2026, 7, 28),
                  ),
                  TodoFile(
                    id: 2,
                    name: 'Work',
                    lastUpdated: DateTime(2026, 7, 30),
                  ),
                ],
                loadCategories: (fileId) async => [
                  Category(
                    id: 21,
                    todoFileId: fileId,
                    name: 'Archive',
                    lastUpdated: DateTime(2026, 7, 27),
                  ),
                  Category(
                    id: 20,
                    todoFileId: fileId,
                    name: 'Projects',
                    lastUpdated: DateTime(2026, 7, 29),
                  ),
                ],
                loadTodos: (categoryId) async => [
                  Todo(
                    id: 201,
                    todoFileId: 2,
                    categoryId: categoryId,
                    name: 'Other note',
                    lastUpdated: DateTime(2026, 7, 28),
                  ),
                  Todo(
                    id: 200,
                    todoFileId: 2,
                    categoryId: categoryId,
                    name: 'Destination',
                    lastUpdated: DateTime(2026, 7, 30),
                  ),
                ],
              );
            },
            child: const Text('Copy note'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Copy note'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a list'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search lists...'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Work')).dy,
      lessThan(tester.getTopLeft(find.text('Personal')).dy),
    );

    await tester.enterText(find.byType(TextField), 'work');
    await tester.pump();
    expect(find.text('Personal'), findsNothing);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(find.text('Work / Choose a category'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search categories...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'proj');
    await tester.pump();
    expect(find.text('Archive'), findsNothing);
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('Work / Projects / Choose a note (optional)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search notes...'), findsOneWidget);
    expect(find.text('Copy to this category'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'dest');
    await tester.pump();
    expect(find.text('Other note'), findsNothing);
    await tester.tap(find.text('Destination'));
    await tester.pumpAndSettle();

    expect(selectedDestination?.fileId, 2);
    expect(selectedDestination?.categoryId, 20);
    expect(selectedDestination?.parentTodoId, 200);
  });

  testWidgets('copy note dialog can select a category without selecting a parent note', (
    tester,
  ) async {
    CopyNoteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selectedDestination = await showCopyNoteDestinationDialog(
                context,
                sourceTodo: const Todo(id: 100, name: 'Source'),
                files: const [TodoFile(id: 2, name: 'Work')],
                loadCategories: (fileId) async => [
                  Category(id: 20, todoFileId: fileId, name: 'Projects'),
                ],
                loadTodos: (categoryId) async => const [],
              );
            },
            child: const Text('Copy note'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Copy note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy to this category'));
    await tester.pumpAndSettle();

    expect(selectedDestination?.fileId, 2);
    expect(selectedDestination?.categoryId, 20);
    expect(selectedDestination?.parentTodoId, isNull);
  });
}

class _PendingStopSpeechController extends SpeechController {
  final stopped = Completer<void>();
  bool stopRequested = false;

  @override
  Future<void> stopListening() {
    stopRequested = true;
    return stopped.future;
  }
}
