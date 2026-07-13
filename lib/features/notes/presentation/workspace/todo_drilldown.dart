import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/widgets/child_task_count_badge.dart';
import 'package:signals/signals.dart';

const desktopTodoColumnWidth = 320.0;
const desktopTodoColumnGap = 16.0;
const desktopTodoDrilldownHorizontalPadding = 40.0;
const desktopTodoDrilldownMinWidth = desktopTodoColumnWidth + desktopTodoDrilldownHorizontalPadding;

class DesktopTodoDrilldown extends StatefulWidget {
  const DesktopTodoDrilldown({
    super.key,
    required this.category,
    required this.todos,
    required this.loadError,
    required this.todoSortOrder,
    required this.selectedTodoPath,
    required this.selectedTodoRevealRequestId,
    required this.expandedTodoId,
    required this.selectedTodo,
    required this.scrollToTopRequestId,
    required this.onCreateTodo,
    required this.onCreateChildTodo,
    required this.onSelectTodo,
    required this.onTodoDuplicate,
    required this.onTodoRename,
    required this.onTodoDelete,
    required this.onTodoToggle,
    required this.onTodoSortMenu,
  });

  final Category category;
  final List<Todo> todos;
  final String? loadError;
  final TodoSortOrder todoSortOrder;
  final List<int> selectedTodoPath;
  final int selectedTodoRevealRequestId;
  final Signal<int?> expandedTodoId;
  final Todo? selectedTodo;
  final int scrollToTopRequestId;
  final VoidCallback? onCreateTodo;
  final ValueChanged<Todo> onCreateChildTodo;
  final ValueChanged<List<int>> onSelectTodo;
  final ValueChanged<Todo> onTodoDuplicate;
  final ValueChanged<Todo> onTodoRename;
  final ValueChanged<Todo> onTodoDelete;
  final ValueChanged<Todo> onTodoToggle;
  final VoidCallback onTodoSortMenu;

  @override
  State<DesktopTodoDrilldown> createState() => _DesktopTodoDrilldownState();
}

class _DesktopTodoDrilldownState extends State<DesktopTodoDrilldown> {
  final _horizontalScrollController = ScrollController();
  final Map<int, ScrollController> _columnScrollControllers = <int, ScrollController>{};
  final Map<int, GlobalKey> _todoTileKeys = <int, GlobalKey>{};
  int _lastHandledSelectedTodoRevealRequestId = 0;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    for (final controller in _columnScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DesktopTodoDrilldown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldScrollToTop = widget.scrollToTopRequestId != oldWidget.scrollToTopRequestId;
    if (shouldScrollToTop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final controller in _columnScrollControllers.values) {
          if (!controller.hasClients) continue;
          controller.animateTo(
            controller.position.minScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = buildTodoColumns(
      widget.todos,
      widget.selectedTodoPath,
      sortOrder: widget.todoSortOrder,
    );
    final visibleTodoIds = widget.todos.map((todo) => todo.id).whereType<int>().toSet();
    _todoTileKeys.removeWhere((todoId, _) => !visibleTodoIds.contains(todoId));
    _columnScrollControllers.removeWhere((index, controller) {
      if (index < columns.length) return false;
      controller.dispose();
      return true;
    });
    if (widget.selectedTodo != null &&
        widget.selectedTodoRevealRequestId != _lastHandledSelectedTodoRevealRequestId) {
      _lastHandledSelectedTodoRevealRequestId = widget.selectedTodoRevealRequestId;
      _scheduleSelectedTodoScroll();
    }
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  widget.category.name,
                  maxLines: 1,
                  minFontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onTodoSortMenu,
                icon: const Icon(Icons.sort_rounded, color: AppColors.textDisabled, size: 20),
                tooltip: 'Sort tasks',
              ),
            ],
          ),
        ),
        if (widget.loadError != null) _TodoLoadErrorBanner(message: widget.loadError!),
        Expanded(
          child: widget.todos.isEmpty
              ? const Center(
                  child: Text('No tasks yet', style: TextStyle(color: AppColors.textSecondary)),
                )
              : LayoutBuilder(
                  builder: (context, constraints) => Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0; index < columns.length; index++) ...[
                              if (index > 0) const SizedBox(width: desktopTodoColumnGap),
                              SizedBox(
                                width: desktopTodoColumnWidth,
                                height: constraints.maxHeight,
                                child: DesktopTodoColumn(
                                  title: index == 0 ? 'Tasks' : 'Children',
                                  todos: columns[index],
                                  allTodos: widget.todos,
                                  controller: _columnScrollControllerForIndex(index),
                                  selectedTodoId: index < widget.selectedTodoPath.length
                                      ? widget.selectedTodoPath[index]
                                      : null,
                                  onSelectTodo: (todo) {
                                    final nextPath = widget.selectedTodoPath.take(index).toList()
                                      ..add(todo.id!);
                                    widget.onSelectTodo(nextPath);
                                  },
                                  onDuplicate: widget.onTodoDuplicate,
                                  onRename: widget.onTodoRename,
                                  onDelete: widget.onTodoDelete,
                                  onToggleDone: widget.onTodoToggle,
                                  onCreateChild: widget.onCreateChildTodo,
                                  todoTileKeyForId: _todoTileKeyForId,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isKeyboardVisible
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.navBackground,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create a new task for this category.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            if (widget.selectedTodo != null)
                              OutlinedButton.icon(
                                onPressed: () => widget.onCreateChildTodo(widget.selectedTodo!),
                                icon: const Icon(Icons.subdirectory_arrow_right_rounded),
                                label: const Text('Add Child Task'),
                              ),
                            ElevatedButton.icon(
                              onPressed: widget.onCreateTodo,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Task'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  GlobalKey _todoTileKeyForId(int todoId) {
    return _todoTileKeys.putIfAbsent(todoId, GlobalKey.new);
  }

  ScrollController _columnScrollControllerForIndex(int index) {
    return _columnScrollControllers.putIfAbsent(index, ScrollController.new);
  }

  void _scheduleSelectedTodoScroll() {
    final selectedTodoId = widget.selectedTodo?.id;
    if (selectedTodoId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectedContext = _todoTileKeys[selectedTodoId]?.currentContext;
      if (selectedContext == null) return;
      Scrollable.ensureVisible(
        selectedContext,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }
}

List<List<Todo>> buildTodoColumns(
  List<Todo> todos,
  List<int> selectedTodoPath, {
  required TodoSortOrder sortOrder,
}) {
  const query = NotesQueryService();
  final columns = <List<Todo>>[];
  int? parentTodoId;
  for (var depth = 0; ; depth++) {
    final columnTodos = query.sortTodos(
      todos.where((todo) => todo.parentTodoId == parentTodoId),
      sortOrder: sortOrder,
    );
    if (columnTodos.isEmpty) {
      break;
    }
    columns.add(columnTodos);
    if (depth >= selectedTodoPath.length) {
      break;
    }
    parentTodoId = selectedTodoPath[depth];
  }
  return columns;
}

class _TodoLoadErrorBanner extends StatelessWidget {
  const _TodoLoadErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(32),
        border: Border.all(color: AppColors.error.withAlpha(120)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load tasks. $message',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopTodoColumn extends StatelessWidget {
  const DesktopTodoColumn({
    super.key,
    required this.title,
    required this.todos,
    required this.allTodos,
    required this.controller,
    required this.selectedTodoId,
    required this.onSelectTodo,
    required this.onDuplicate,
    required this.onRename,
    required this.onDelete,
    required this.onToggleDone,
    required this.onCreateChild,
    required this.todoTileKeyForId,
  });

  final String title;
  final List<Todo> todos;
  final List<Todo> allTodos;
  final ScrollController controller;
  final int? selectedTodoId;
  final ValueChanged<Todo> onSelectTodo;
  final ValueChanged<Todo> onDuplicate;
  final ValueChanged<Todo> onRename;
  final ValueChanged<Todo> onDelete;
  final ValueChanged<Todo> onToggleDone;
  final ValueChanged<Todo> onCreateChild;
  final GlobalKey Function(int todoId) todoTileKeyForId;

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final listPadding = isKeyboardVisible
        ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
        : const EdgeInsets.all(12);
    final itemSpacing = isKeyboardVisible ? 6.0 : 10.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(120),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            if (!isKeyboardVisible) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${todos.length}',
                        style: const TextStyle(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Divider(height: 1)),
            ],
            SliverPadding(
              padding: listPadding,
              sliver: SliverList.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) => Padding(
                  key: todos[index].id == null ? null : todoTileKeyForId(todos[index].id!),
                  padding: EdgeInsets.only(bottom: itemSpacing),
                  child: DesktopTodoTile(
                    todo: todos[index],
                    childTaskCount: allTodos
                        .where((todo) => todo.parentTodoId == todos[index].id)
                        .length,
                    isSelected: selectedTodoId == todos[index].id,
                    onTap: () => onSelectTodo(todos[index]),
                    onDuplicate: () => onDuplicate(todos[index]),
                    onRename: () => onRename(todos[index]),
                    onDelete: () => onDelete(todos[index]),
                    onToggleDone: () => onToggleDone(todos[index]),
                    onCreateChild: () => onCreateChild(todos[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopTodoTile extends StatelessWidget {
  const DesktopTodoTile({
    super.key,
    required this.todo,
    required this.childTaskCount,
    required this.isSelected,
    required this.onTap,
    required this.onDuplicate,
    required this.onRename,
    required this.onDelete,
    required this.onToggleDone,
    required this.onCreateChild,
  });

  final Todo todo;
  final int childTaskCount;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;
  final VoidCallback onCreateChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.selectedSurface : AppColors.background.withAlpha(70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.selectedBorder : AppColors.cardBorder,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: isSelected
            ? const [BoxShadow(color: Color(0x403E67FF), blurRadius: 14, offset: Offset(0, 8))]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(isSelected ? 12 : 16, 0, 8, 0),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  width: 4,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.selectedBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              Checkbox(value: todo.done, onChanged: (_) => onToggleDone()),
            ],
          ),
          title: Text(
            todo.name,
            style: TextStyle(
              color: todo.done
                  ? (isSelected ? Colors.white70 : AppColors.textDisabled)
                  : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              decoration: todo.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: todo.parentTodoId == null
              ? null
              : Text(
                  'Child task',
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChildTaskCountBadge(count: childTaskCount, isSelected: isSelected),
              PopupMenuButton<String>(
                color: AppColors.surface,
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textDisabled),
                onSelected: (value) {
                  switch (value) {
                    case 'add-child':
                      onCreateChild();
                    case 'rename':
                      onRename();
                    case 'duplicate':
                      onDuplicate();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'add-child', child: Text('Add Child Task')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate Task')),
                  PopupMenuItem(value: 'rename', child: Text('Rename Task')),
                  PopupMenuItem(value: 'delete', child: Text('Delete Task')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
