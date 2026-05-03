import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_drilldown.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_notes_pane.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:signals/signals.dart';

const desktopCategoryRailWidth = 320.0;

class DesktopWorkspaceEmptyState extends StatelessWidget {
  const DesktopWorkspaceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.space_dashboard_outlined, size: 56, color: AppColors.textDisabled),
          SizedBox(height: 16),
          Text(
            'Select a list',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pick something from the left to open it here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class DesktopNotesPanel extends StatelessWidget {
  const DesktopNotesPanel({
    super.key,
    required this.file,
    required this.categories,
    required this.categoryTaskCounts,
    required this.category,
    required this.todos,
    required this.todoSortOrder,
    required this.selectedTodo,
    required this.selectedTodoPath,
    required this.expandedTodoId,
    required this.onCreateTodo,
    required this.onCreateChildTodo,
    required this.onSelectCategory,
    required this.onSelectTodo,
    required this.onTodoDuplicate,
    required this.onTodoRename,
    required this.onTodoDelete,
    required this.onTodoToggle,
    required this.onSaveTodoNotes,
    required this.onCategoryActions,
    required this.onCategorySortMenu,
    required this.onTodoSortMenu,
    required this.speech,
  });

  final TodoFile file;
  final List<Category> categories;
  final Map<int, int> categoryTaskCounts;
  final Category? category;
  final List<Todo> todos;
  final TodoSortOrder todoSortOrder;
  final Todo? selectedTodo;
  final List<int> selectedTodoPath;
  final Signal<int?> expandedTodoId;
  final VoidCallback? onCreateTodo;
  final ValueChanged<Todo> onCreateChildTodo;
  final ValueChanged<Category> onSelectCategory;
  final ValueChanged<List<int>> onSelectTodo;
  final ValueChanged<Todo> onTodoDuplicate;
  final ValueChanged<Todo> onTodoRename;
  final ValueChanged<Todo> onTodoDelete;
  final ValueChanged<Todo> onTodoToggle;
  final Future<void> Function(Todo todo, String notes) onSaveTodoNotes;
  final VoidCallback? onCategoryActions;
  final VoidCallback onCategorySortMenu;
  final VoidCallback onTodoSortMenu;
  final SpeechController speech;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category == null
                          ? 'Choose a category to start editing.'
                          : 'Editing ${category!.name}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: desktopCategoryRailWidth,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.divider)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Categories',
                            style: TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onCategorySortMenu,
                          icon: const Icon(
                            Icons.sort_rounded,
                            color: AppColors.textDisabled,
                            size: 20,
                          ),
                          tooltip: 'Sort categories',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...categories.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => onSelectCategory(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                boxShadow: category?.id == item.id
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x403E67FF),
                                          blurRadius: 14,
                                          offset: Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                                color: category?.id == item.id
                                    ? AppColors.selectedSurface
                                    : AppColors.surfaceVariant.withAlpha(100),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: category?.id == item.id
                                      ? AppColors.selectedBorder
                                      : AppColors.cardBorder,
                                  width: category?.id == item.id ? 1.6 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (category?.id == item.id)
                                    Container(
                                      width: 4,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.selectedBorder,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              color: category?.id == item.id
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: category?.id == item.id
                                                ? AppColors.selectedSurfaceStrong
                                                : AppColors.badge,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${categoryTaskCounts[item.id] ?? 0}',
                                            style: TextStyle(
                                              color: category?.id == item.id
                                                  ? Colors.white
                                                  : AppColors.badgeText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (category?.id == item.id && onCategoryActions != null)
                                    IconButton(
                                      onPressed: onCategoryActions,
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        color: AppColors.textDisabled,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: category == null
                    ? const DesktopWorkspaceEmptyState()
                    : Row(
                        children: [
                          SizedBox(
                            width: desktopTodoDrilldownMinWidth,
                            child: DesktopTodoDrilldown(
                              category: category!,
                              todos: todos,
                              todoSortOrder: todoSortOrder,
                              selectedTodoPath: selectedTodoPath,
                              expandedTodoId: expandedTodoId,
                              selectedTodo: selectedTodo,
                              onCreateTodo: onCreateTodo,
                              onCreateChildTodo: onCreateChildTodo,
                              onSelectTodo: onSelectTodo,
                              onTodoDuplicate: onTodoDuplicate,
                              onTodoRename: onTodoRename,
                              onTodoDelete: onTodoDelete,
                              onTodoToggle: onTodoToggle,
                              onTodoSortMenu: onTodoSortMenu,
                            ),
                          ),
                          Expanded(
                            child: DesktopTodoNotesPane(
                              todo: selectedTodo,
                              onSave: onSaveTodoNotes,
                              speech: speech,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
