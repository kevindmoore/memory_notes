import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/presentation/workspace/notes_workspace_panel.dart';

void main() {
  testWidgets('desktop pane divider supports resize and reset', (tester) async {
    var resizeDelta = 0.0;
    var resizeEndCount = 0;
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: Row(
              children: [
                const SizedBox(width: 100),
                DesktopPaneDivider(
                  key: const ValueKey('divider'),
                  onResize: (delta) => resizeDelta += delta,
                  onResizeEnd: () => resizeEndCount++,
                  onReset: () => resetCount++,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final divider = find.byKey(const ValueKey('divider'));
    final mouseRegion = tester.widget<MouseRegion>(
      find.descendant(
        of: divider,
        matching: find.byWidgetPredicate(
          (widget) => widget is MouseRegion && widget.cursor == SystemMouseCursors.resizeColumn,
        ),
      ),
    );
    expect(mouseRegion.cursor, SystemMouseCursors.resizeColumn);

    await tester.drag(divider, const Offset(60, 0));
    await tester.pump();

    expect(resizeDelta, greaterThan(0));
    expect(resizeEndCount, 1);

    await tester.tap(divider);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(divider);
    await tester.pump(const Duration(milliseconds: 50));

    expect(resetCount, 1);
  });
}
