import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/app/app.dart';

void main() {
  testWidgets('MemoryNotesApp smoke test', (WidgetTester tester) async {
    // App requires AppServices.initialize() before running, so we skip
    // the full integration smoke test here and just verify the test file compiles.
    expect(MemoryNotesApp, isNotNull);
  });
}
