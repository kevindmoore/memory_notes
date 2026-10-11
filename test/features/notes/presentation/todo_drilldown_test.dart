import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_drilldown.dart';
import 'package:signals/signals.dart';

void main() {
  testWidgets('restored task selection keeps the existing scroll offset', (tester) async {
    final todos = List.generate(
      12,
      (index) => Todo(
        id: index + 1,
        name: 'Task ${(index + 1).toString().padLeft(2, '0')}',
      ),
    );

    await tester.pumpWidget(_TestApp(todos: todos, revealRequestId: 0));
    await tester.pumpAndSettle();

    final taskList = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    taskList.controller!.jumpTo(250);
    await tester.pump();

    await tester.pumpWidget(_TestApp(todos: todos, revealRequestId: 0));
    await tester.pumpAndSettle();

    expect(taskList.controller!.offset, 250);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.todos, required this.revealRequestId});

  final List<Todo> todos;
  final int revealRequestId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          height: 500,
          child: DesktopTodoDrilldown(
            category: const Category(id: 1, name: 'Category', todoFileId: 1),
            todos: todos,
            loadError: null,
            todoSortOrder: TodoSortOrder.nameAZ,
            selectedTodoPath: const [1],
            selectedTodoRevealRequestId: revealRequestId,
            expandedTodoId: signal<int?>(null),
            selectedTodo: todos.first,
            scrollToTopRequestId: 0,
            onCreateTodo: null,
            onCreateChildTodo: _onTodo,
            onSelectTodo: _onPath,
            onTodoDuplicate: _onTodo,
            onTodoRename: _onTodo,
            onTodoDelete: _onTodo,
            onTodoToggle: _onTodo,
            onTodoSortMenu: _onVoid,
          ),
        ),
      ),
    );
  }
}

void _onVoid() {}

void _onTodo(Todo todo) {}

void _onPath(List<int> path) {}
