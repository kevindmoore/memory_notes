import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/presentation/widgets/child_task_count_badge.dart';

void main() {
  testWidgets('ChildTaskCountBadge fits inside the child task action slot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(child: ChildTaskCountBadge(count: 12)),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
