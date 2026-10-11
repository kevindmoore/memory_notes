import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_drilldown.dart';
import 'package:signals/signals.dart';

void main() {
  testWidgets('task overflow menu includes Delete Task', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: DesktopTodoTile(
            todo: Todo(id: 1, name: 'Task'),
            childTaskCount: 0,
            isSelected: false,
            onTap: _noop,
            onDuplicate: _noop,
            onRename: _noop,
            onDelete: _noop,
            onToggleDone: _noop,
            onCreateChild: _noop,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Delete Task'), findsOneWidget);
  });

  testWidgets('only the list containing the current child has the stronger border', (
    tester,
  ) async {
    const parentTodo = Todo(id: 1, name: 'Parent task');
    const childTodo = Todo(id: 2, name: 'Child task', parentTodoId: 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: DesktopTodoDrilldown(
            category: const Category(id: 1, name: 'Test category', todoFileId: 1),
            todos: const [parentTodo, childTodo],
            loadError: null,
            todoSortOrder: TodoSortOrder.newest,
            selectedTodoPath: const [1, 2],
            expandedTodoId: signal<int?>(null),
            selectedTodo: childTodo,
            scrollToTopRequestId: 0,
            onCreateTodo: _noop,
            onCreateChildTodo: _todoNoop,
            onSelectTodo: _pathNoop,
            onTodoDuplicate: _todoNoop,
            onTodoRename: _todoNoop,
            onTodoDelete: _todoNoop,
            onTodoToggle: _todoNoop,
            onTodoSortMenu: _noop,
          ),
        ),
      ),
    );

    final currentColumnFinder = find.byWidgetPredicate(
      (widget) => widget is DesktopTodoColumn && widget.isCurrent,
    );
    expect(currentColumnFinder, findsOneWidget);

    final currentColumn = tester.widget<DecoratedBox>(
      find.descendant(of: currentColumnFinder, matching: find.byType(DecoratedBox)).first,
    );
    final currentDecoration = currentColumn.decoration as BoxDecoration;
    final currentBorder = currentDecoration.border! as Border;
    final currentColumnWidget = tester.widget<DesktopTodoColumn>(currentColumnFinder);

    expect(currentColumnWidget.title, 'Children');
    expect(currentBorder.top.color, AppColors.accentLight);
    expect(currentBorder.top.width, 3);
  });

  testWidgets('todo drilldown fits when the keyboard is visible on a short display', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 360));
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetViewInsets();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: DesktopTodoDrilldown(
            category: const Category(id: 1, name: 'Test category', todoFileId: 1),
            todos: const [Todo(id: 1, name: 'Parent task')],
            loadError: null,
            todoSortOrder: TodoSortOrder.newest,
            selectedTodoPath: const [],
            expandedTodoId: signal<int?>(null),
            selectedTodo: null,
            scrollToTopRequestId: 0,
            onCreateTodo: _noop,
            onCreateChildTodo: _todoNoop,
            onSelectTodo: _pathNoop,
            onTodoDuplicate: _todoNoop,
            onTodoRename: _todoNoop,
            onTodoDelete: _todoNoop,
            onTodoToggle: _todoNoop,
            onTodoSortMenu: _noop,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

void _todoNoop(Todo todo) {}

void _pathNoop(List<int> path) {}
