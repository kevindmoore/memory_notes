import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/workspace/notes_workspace_panel.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:signals/signals.dart';

void main() {
  testWidgets('category list has an Add Category button', (tester) async {
    var createCategoryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: DesktopNotesPanel(
            file: const TodoFile(id: 1, name: 'List'),
            categories: const [],
            categoryTaskCounts: const {},
            category: null,
            todos: const [],
            todoLoadError: null,
            todoSortOrder: TodoSortOrder.newest,
            selectedTodo: null,
            selectedTodoPath: const [],
            todoNotesFocusRequestId: 0,
            todoListScrollToTopRequestId: 0,
            expandedTodoId: signal<int?>(null),
            categoryRailWidth: desktopCategoryRailWidth,
            todoDrilldownWidth: 360,
            onCreateCategory: () => createCategoryCount++,
            onCreateTodo: null,
            onCreateChildTodo: _todoNoop,
            onSelectCategory: _categoryNoop,
            onSelectTodo: _pathNoop,
            onTodoDuplicate: _todoNoop,
            onTodoRename: _todoNoop,
            onTodoDelete: _todoNoop,
            onTodoToggle: _todoNoop,
            onSaveTodoNotes: _saveNoop,
            onCategoryActions: null,
            onCategorySortMenu: _noop,
            onTodoSortMenu: _noop,
            onCategoryRailResize: _resizeNoop,
            onCategoryRailResizeEnd: _noop,
            onCategoryRailReset: _noop,
            onTodoDrilldownResize: _resizeNoop,
            onTodoDrilldownResizeEnd: _noop,
            onTodoDrilldownReset: _noop,
            speech: SpeechController(),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Category'));

    expect(createCategoryCount, 1);
  });
}

void _noop() {}

void _resizeNoop(double delta) {}

void _categoryNoop(Category category) {}

void _todoNoop(Todo todo) {}

void _pathNoop(List<int> path) {}

Future<void> _saveNoop(Todo todo, String notes) async {}
