import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_notes_pane.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';

void main() {
  testWidgets('failed autosave retains text, stops retrying, and allows explicit retry', (tester) async {
    var fail = true;
    var saves = 0;
    var savedText = '';
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: DesktopTodoNotesPane(
        todo: const Todo(id: 1, name: 'Task', notes: 'Original'),
        focusRequestId: 0,
        speech: SpeechController(),
        onSave: (todo, notes) async {
          saves++;
          if (fail) throw StateError('Offline');
          savedText = notes;
        },
      ),
    )));
    await tester.enterText(find.byType(TextField), 'Unsaved draft');
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Couldn’t save. Your text is still here.'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Unsaved draft');
    await tester.pump(const Duration(seconds: 30));
    expect(saves, 1);
    expect(tester.takeException(), isNull);

    fail = false;
    await tester.tap(find.text('Retry save'));
    await tester.pump();
    expect(savedText, 'Unsaved draft');
    expect(find.text('Retry save'), findsNothing);
  });
}
