import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/mobile_note_edit_view_state.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/notes/presentation/dialogs/notes_dialogs.dart';
import 'package:memory_notes/features/notes/presentation/widgets/child_task_count_badge.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage(name: 'NoteEditRoute')
class NoteEditScreen extends StatefulWidget {
  final int fileId;
  final int categoryId;
  final int? parentTodoId;
  final int? focusedTodoId;
  final bool openFocusedTodoNotes;
  final NotesMobileStore notesMobile;
  final NoteEditActions noteEditActions;
  final SpeechController speech;

  const NoteEditScreen({
    @PathParam('fileId') required this.fileId,
    @PathParam('categoryId') required this.categoryId,
    this.parentTodoId,
    this.focusedTodoId,
    this.openFocusedTodoNotes = false,
    required this.notesMobile,
    required this.noteEditActions,
    required this.speech,
    super.key,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _taskController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchQuery = signal('');
  TodoSortOrder _todoSortOrder = TodoSortOrder.newest;
  bool _didLoad = false;

  static const _categoryActions = [
    NotesActionSheetItem(
      value: 'duplicate',
      label: 'Duplicate Category',
      icon: Icons.copy_rounded,
    ),
    NotesActionSheetItem(
      value: 'rename',
      label: 'Rename Category',
      icon: Icons.edit_outlined,
    ),
    NotesActionSheetItem(
      value: 'delete',
      label: 'Delete Category',
      icon: Icons.delete_outline_rounded,
      color: AppColors.error,
    ),
  ];

  static const _todoActions = [
    NotesActionSheetItem(
      value: 'addChild',
      label: 'Add Child Task',
      icon: Icons.subdirectory_arrow_right_rounded,
    ),
    NotesActionSheetItem(
      value: 'duplicate',
      label: 'Duplicate Task',
      icon: Icons.copy_rounded,
    ),
    NotesActionSheetItem(
      value: 'rename',
      label: 'Rename Task',
      icon: Icons.edit_outlined,
    ),
    NotesActionSheetItem(
      value: 'delete',
      label: 'Delete Task',
      icon: Icons.delete_outline_rounded,
      color: AppColors.error,
    ),
  ];

  static const _todoSortActions = [
    NotesActionSheetItem(
      value: TodoSortOrder.newest,
      label: 'Sort Tasks: Newest first',
      icon: Icons.schedule_rounded,
    ),
    NotesActionSheetItem(
      value: TodoSortOrder.nameAZ,
      label: 'Sort Tasks: Name A to Z',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: TodoSortOrder.nameZA,
      label: 'Sort Tasks: Name Z to A',
      icon: Icons.sort_by_alpha_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => _searchQuery.value = _searchController.text.trim().toLowerCase(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notesMobile.loadCategory(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final viewState = widget.notesMobile.buildNoteEditViewState(
        fileId: widget.fileId,
        categoryId: widget.categoryId,
        parentTodoId: widget.parentTodoId,
        focusedTodoId: widget.focusedTodoId,
        searchQuery: _searchQuery.value,
        openFocusedTodoNotes: widget.openFocusedTodoNotes,
        todoSortOrder: _todoSortOrder,
      );

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.maybePop();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MobileNoteBreadcrumbBar(
                fileName: viewState.fileName,
                category: viewState.category,
                allTodos: viewState.allTodos,
                parentTodo: viewState.parentTodo,
                focusedTodo: viewState.focusedTodo,
                showFocusedTodo: widget.openFocusedTodoNotes,
                onNavigate: _navigateToBreadcrumb,
              ),
              const SizedBox(height: 4),
              Text(
                viewState.screenTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          toolbarHeight: 84,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              onPressed: () {
                final activeTodo = viewState.focusedTodo ?? viewState.parentTodo;
                if (activeTodo != null) {
                  _showTodoMenu(context, activeTodo);
                } else if (viewState.category != null) {
                  _showCategoryMenu(context, viewState.category!);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.openFocusedTodoNotes && viewState.focusedTodo != null)
              Expanded(
                child: _buildTodoNotesView(viewState.focusedTodo!),
              )
            else ...[
              _buildSearchBar(),
              _buildTaskHeader(),
              Expanded(
                child: _buildTodoList(context, viewState),
              ),
              _buildInputBar(),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: AppColors.textPrimary),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search_rounded, color: AppColors.textDisabled, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: Watch((context) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpeechMicButton(
                    controller: _searchController,
                    speech: widget.speech,
                    appendToExistingText: false,
                    onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    ),
                  ),
                  if (_searchQuery.value.isNotEmpty)
                    IconButton(
                      icon:
                          const Icon(Icons.close_rounded, color: AppColors.textDisabled, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery.value = '';
                      },
                    ),
                ],
              )),
          fillColor: AppColors.surfaceVariant,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Tasks',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showTodoSortMenu(context),
            icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary),
            tooltip: 'Sort tasks',
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_outlined, size: 48, color: AppColors.textDisabled),
          SizedBox(height: 16),
          Text('No tasks yet',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Add a new task below',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBackground,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.only(
          left: 16,
          right: 12,
          top: 12,
          bottom: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.textDisabled, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: const InputDecoration(
                              hintText: 'Add a new task...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _submitTask(),
                          ),
                        ),
                        SpeechMicButton(
                          controller: _taskController,
                          speech: widget.speech,
                          onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitTask,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isKeyboardVisible
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _QuickActionChip(
                              icon: Icons.note_outlined,
                              label: 'Add Note',
                              onTap: _showAddNoteDialog,
                            ),
                            const SizedBox(width: 12),
                            _QuickActionChip(
                              icon: Icons.subdirectory_arrow_right_rounded,
                              label: 'Add Subtask',
                              onTap: () {
                                final parentTodoId = widget.parentTodoId;
                                if (parentTodoId == null) return;
                                _showAddSubtaskDialog(parentTodoId);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoNotesView(Todo todo) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.navBackground,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Task Notes',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _TodoNotesEditor(
            todo: todo,
            speech: widget.speech,
            onSave: (notes) => widget.noteEditActions.saveTodoNotes(
              todo: todo,
              notes: notes,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    MobileNoteEditViewState viewState,
  ) {
    if (viewState.visibleTodos.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: viewState.visibleTodos.length,
      itemBuilder: (context, i) {
        final todo = viewState.visibleTodos[i];
        final childTaskCount =
            viewState.allTodos.where((item) => item.parentTodoId == todo.id).length;
        return _TodoTaskTile(
          todo: todo,
          childTaskCount: childTaskCount,
          onOpenChildren: childTaskCount > 0 ? () => _openTodoChildren(todo) : null,
          onOpenNotes: () => _openTodoNotes(todo),
          isFocused: widget.focusedTodoId == todo.id,
          onToggleDone: () => widget.notesMobile.toggleTodo(todo),
          onRename: () => _showRenameTodoDialog(context, todo),
          onAddChild: () => _showAddSubtaskDialog(todo.id!),
          onDuplicate: () async {
            final duplicateName = await showNotesTextPromptDialog(
              context,
              title: 'Duplicate Task',
              hintText: 'Task name',
              confirmLabel: 'Duplicate',
              initialValue: '${todo.name} (Copy)',
              speech: widget.speech,
            );
            if (duplicateName == null) return;
            await widget.noteEditActions.duplicateTodo(
              todo: todo,
              name: duplicateName,
            );
          },
          onDelete: () => widget.notesMobile.deleteTodo(todo),
        );
      },
    );
  }

  Future<void> _submitTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    _taskController.clear();
    await widget.notesMobile.addTodo(
      fileId: widget.fileId,
      categoryId: widget.categoryId,
      name: text,
      parentTodoId: widget.parentTodoId,
    );
  }

  Future<void> _showAddNoteDialog() async {
    final notes = await showNotesTextPromptDialog(
      context,
      title: 'Internal Note',
      hintText: 'Write a note...',
      confirmLabel: 'Add',
      multiline: true,
      speech: widget.speech,
    );
    if (notes == null) return;
    await widget.noteEditActions.addNote(
      fileId: widget.fileId,
      categoryId: widget.categoryId,
      notes: notes,
      parentTodoId: widget.parentTodoId,
    );
  }

  Future<void> _showAddSubtaskDialog(int parentTodoId) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'New Subtask',
      hintText: 'Subtask name',
      confirmLabel: 'Add',
      speech: widget.speech,
    );
    if (name == null) return;
    await widget.noteEditActions.addSubtask(
      fileId: widget.fileId,
      categoryId: widget.categoryId,
      parentTodoId: parentTodoId,
      name: name,
    );
  }

  Future<void> _openTodoChildren(Todo todo) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: _mobileTodoChildrenRouteName(todo.id)),
        builder: (_) => NoteEditScreen(
          fileId: widget.fileId,
          categoryId: widget.categoryId,
          parentTodoId: todo.id,
          focusedTodoId: todo.id,
          openFocusedTodoNotes: false,
          notesMobile: widget.notesMobile,
          noteEditActions: widget.noteEditActions,
          speech: widget.speech,
        ),
      ),
    );
  }

  Future<void> _openTodoNotes(Todo todo) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: _mobileTodoNotesRouteName(todo.id)),
        builder: (_) => NoteEditScreen(
          fileId: widget.fileId,
          categoryId: widget.categoryId,
          parentTodoId: widget.parentTodoId,
          focusedTodoId: todo.id,
          openFocusedTodoNotes: true,
          notesMobile: widget.notesMobile,
          noteEditActions: widget.noteEditActions,
          speech: widget.speech,
        ),
      ),
    );
  }

  void _navigateToBreadcrumb(_MobileNoteBreadcrumbTarget target) {
    FocusManager.instance.primaryFocus?.unfocus();
    switch (target.type) {
      case _MobileNoteBreadcrumbTargetType.file:
        Navigator.of(context).popUntil(
          (route) => route.settings.name == NoteDetailRoute.name || route.isFirst,
        );
      case _MobileNoteBreadcrumbTargetType.category:
        Navigator.of(context).popUntil(
          (route) => route.settings.name == NoteEditRoute.name || route.isFirst,
        );
        if (!mounted || widget.parentTodoId != null || widget.openFocusedTodoNotes) {
          return;
        }
        _replaceWithNoteEditRoute(
          parentTodoId: null,
          focusedTodoId: null,
          openFocusedTodoNotes: false,
        );
      case _MobileNoteBreadcrumbTargetType.todo:
        final todoId = target.todo?.id;
        if (todoId == null) return;
        var foundExistingRoute = false;
        Navigator.of(context).popUntil((route) {
          foundExistingRoute = route.settings.name == _mobileTodoChildrenRouteName(todoId);
          return foundExistingRoute || route.settings.name == NoteEditRoute.name || route.isFirst;
        });
        return;
    }
  }

  void _replaceWithNoteEditRoute({
    required int? parentTodoId,
    required int? focusedTodoId,
    required bool openFocusedTodoNotes,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => NoteEditScreen(
          fileId: widget.fileId,
          categoryId: widget.categoryId,
          parentTodoId: parentTodoId,
          focusedTodoId: focusedTodoId,
          openFocusedTodoNotes: openFocusedTodoNotes,
          notesMobile: widget.notesMobile,
          noteEditActions: widget.noteEditActions,
          speech: widget.speech,
        ),
      ),
    );
  }

  String _mobileTodoChildrenRouteName(int? todoId) => 'mobileTodoChildren:$todoId';

  String _mobileTodoNotesRouteName(int? todoId) => 'mobileTodoNotes:$todoId';

  Future<void> _showCategoryMenu(BuildContext context, Category category) async {
    final action = await showNotesActionSheet<String>(context, actions: _categoryActions);

    switch (action) {
      case 'rename':
        if (!context.mounted) return;
        final name = await showNotesTextPromptDialog(
          context,
          title: 'Rename Category',
          hintText: 'Category name',
          confirmLabel: 'Rename',
          initialValue: category.name,
          speech: widget.speech,
        );
        if (name == null || name == category.name) return;
        await widget.noteEditActions.renameCategory(
          category: category,
          name: name,
        );
      case 'duplicate':
        if (!context.mounted) return;
        final duplicateName = await showNotesTextPromptDialog(
          context,
          title: 'Duplicate Category',
          hintText: 'Category name',
          confirmLabel: 'Duplicate',
          initialValue: '${category.name} (Copy)',
          speech: widget.speech,
        );
        if (duplicateName == null) return;
        await widget.noteEditActions.duplicateCategory(
          category: category,
          name: duplicateName,
        );
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await showNotesConfirmDialog(
          context,
          title: 'Delete Category?',
          message: 'Delete "${category.name}" and all its tasks?',
          confirmLabel: 'Delete',
        );
        if (confirmed) {
          await widget.noteEditActions.deleteCategory(
            categoryId: category.id!,
          );
          if (context.mounted) {
            context.maybePop();
          }
        }
      case null:
        return;
    }
  }

  Future<void> _showRenameTodoDialog(BuildContext context, Todo todo) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'Rename Task',
      hintText: 'Task name',
      confirmLabel: 'Rename',
      initialValue: todo.name,
      speech: widget.speech,
    );
    if (name == null || name == todo.name) return;
    await widget.noteEditActions.renameTodo(
      todo: todo,
      name: name,
    );
  }

  Future<void> _showTodoMenu(BuildContext context, Todo todo) async {
    final action = await showNotesActionSheet<String>(context, actions: _todoActions);

    switch (action) {
      case 'addChild':
        if (todo.id == null) return;
        await _showAddSubtaskDialog(todo.id!);
      case 'rename':
        if (!context.mounted) return;
        await _showRenameTodoDialog(context, todo);
      case 'duplicate':
        if (!context.mounted) return;
        final duplicateName = await showNotesTextPromptDialog(
          context,
          title: 'Duplicate Task',
          hintText: 'Task name',
          confirmLabel: 'Duplicate',
          initialValue: '${todo.name} (Copy)',
          speech: widget.speech,
        );
        if (duplicateName == null) return;
        await widget.noteEditActions.duplicateTodo(
          todo: todo,
          name: duplicateName,
        );
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await showNotesConfirmDialog(
          context,
          title: 'Delete Task?',
          message: 'Delete "${todo.name}"?',
          confirmLabel: 'Delete',
        );
        if (!confirmed) return;
        await widget.noteEditActions.deleteTodo(todo: todo);
        if (context.mounted) {
          context.maybePop();
        }
      case null:
        return;
    }
  }

  Future<void> _showTodoSortMenu(BuildContext context) async {
    final action = await showNotesActionSheet<TodoSortOrder>(
      context,
      actions: _todoSortActions,
    );
    if (action != null) {
      setState(() => _todoSortOrder = action);
    }
  }
}

enum _MobileNoteBreadcrumbTargetType { file, category, todo }

class _MobileNoteBreadcrumbTarget {
  const _MobileNoteBreadcrumbTarget.file()
      : type = _MobileNoteBreadcrumbTargetType.file,
        todo = null;

  const _MobileNoteBreadcrumbTarget.category()
      : type = _MobileNoteBreadcrumbTargetType.category,
        todo = null;

  const _MobileNoteBreadcrumbTarget.todo(this.todo) : type = _MobileNoteBreadcrumbTargetType.todo;

  final _MobileNoteBreadcrumbTargetType type;
  final Todo? todo;
}

class _MobileNoteBreadcrumbBar extends StatelessWidget {
  const _MobileNoteBreadcrumbBar({
    required this.fileName,
    required this.category,
    required this.allTodos,
    required this.parentTodo,
    required this.focusedTodo,
    required this.showFocusedTodo,
    required this.onNavigate,
  });

  final String fileName;
  final Category? category;
  final List<Todo> allTodos;
  final Todo? parentTodo;
  final Todo? focusedTodo;
  final bool showFocusedTodo;
  final ValueChanged<_MobileNoteBreadcrumbTarget> onNavigate;

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();
    return SizedBox(
      height: 26,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: segments.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 15),
        ),
        itemBuilder: (context, index) {
          final segment = segments[index];
          final isLast = index == segments.length - 1;
          return _MobileNoteBreadcrumbChip(
            icon: segment.icon,
            label: segment.label,
            isCurrent: isLast,
            onTap: isLast ? null : () => onNavigate(segment.target),
          );
        },
      ),
    );
  }

  List<_MobileNoteBreadcrumbSegment> _buildSegments() {
    final segments = <_MobileNoteBreadcrumbSegment>[
      _MobileNoteBreadcrumbSegment(
        icon: Icons.home_rounded,
        label: fileName.isEmpty ? 'Lists' : fileName,
        target: const _MobileNoteBreadcrumbTarget.file(),
      ),
    ];

    final selectedCategory = category;
    if (selectedCategory == null) {
      return segments;
    }
    segments.add(
      _MobileNoteBreadcrumbSegment(
        icon: Icons.folder_rounded,
        label: selectedCategory.name,
        target: const _MobileNoteBreadcrumbTarget.category(),
      ),
    );

    final activeTodo = showFocusedTodo ? focusedTodo : parentTodo;
    final todoPath = _todoPathFor(activeTodo);
    for (final todo in todoPath) {
      segments.add(
        _MobileNoteBreadcrumbSegment(
          icon: Icons.check_circle_outline_rounded,
          label: todo.name,
          target: _MobileNoteBreadcrumbTarget.todo(todo),
        ),
      );
    }

    return segments;
  }

  List<Todo> _todoPathFor(Todo? todo) {
    if (todo?.id == null) {
      return const <Todo>[];
    }
    final todosById = {
      for (final item in allTodos)
        if (item.id != null) item.id!: item,
    };
    final path = <Todo>[];
    var cursor = todo;
    final visited = <int>{};
    while (cursor?.id != null && visited.add(cursor!.id!)) {
      path.add(cursor);
      final parentId = cursor.parentTodoId;
      cursor = parentId == null ? null : todosById[parentId];
    }
    return path.reversed.toList(growable: false);
  }
}

class _MobileNoteBreadcrumbSegment {
  const _MobileNoteBreadcrumbSegment({
    required this.icon,
    required this.label,
    required this.target,
  });

  final IconData icon;
  final String label;
  final _MobileNoteBreadcrumbTarget target;
}

class _MobileNoteBreadcrumbChip extends StatelessWidget {
  const _MobileNoteBreadcrumbChip({
    required this.icon,
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent ? AppColors.textPrimary : AppColors.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoNotesEditor extends StatefulWidget {
  const _TodoNotesEditor({
    required this.todo,
    required this.onSave,
    required this.speech,
  });

  final Todo todo;
  final Future<void> Function(String notes) onSave;
  final SpeechController speech;

  @override
  State<_TodoNotesEditor> createState() => _TodoNotesEditorState();
}

class _TodoNotesEditorState extends State<_TodoNotesEditor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _saveTimer;
  String _lastSavedNotes = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setControllerText(widget.todo.notes);
    _lastSavedNotes = widget.todo.notes;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TodoNotesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo.id != widget.todo.id) {
      _saveTimer?.cancel();
      _setControllerText(widget.todo.notes);
      _lastSavedNotes = widget.todo.notes;
      return;
    }

    final storeNotesChanged = oldWidget.todo.notes != widget.todo.notes;
    final userHasPendingEdits = _controller.text != _lastSavedNotes;
    if (storeNotesChanged && !_focusNode.hasFocus && !userHasPendingEdits) {
      _setControllerText(widget.todo.notes);
      _lastSavedNotes = widget.todo.notes;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'Saving...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              SpeechMicButton(
                controller: _controller,
                speech: widget.speech,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              expands: true,
              maxLines: null,
              minLines: null,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Write notes for this task...',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _scheduleAutosave(),
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      unawaited(_flushSave());
    }
  }

  void _scheduleAutosave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_flushSave());
    });
  }

  Future<void> _flushSave() async {
    _saveTimer?.cancel();
    final notes = _controller.text;
    if (_isSaving || notes == _lastSavedNotes) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(notes);
      _lastSavedNotes = notes;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (_controller.text != _lastSavedNotes) {
      if (_focusNode.hasFocus) {
        _scheduleAutosave();
      } else {
        unawaited(_flushSave());
      }
    }
  }

  void _setControllerText(String notes) {
    _controller.value = TextEditingValue(
      text: notes,
      selection: TextSelection.collapsed(offset: notes.length),
    );
  }
}

class _TodoTaskTile extends StatelessWidget {
  final Todo todo;
  final int childTaskCount;
  final VoidCallback? onOpenChildren;
  final VoidCallback onOpenNotes;
  final bool isFocused;
  final VoidCallback onToggleDone;
  final Future<void> Function() onAddChild;
  final Future<void> Function() onRename;
  final Future<void> Function() onDuplicate;
  final Future<void> Function() onDelete;

  const _TodoTaskTile({
    required this.todo,
    required this.childTaskCount,
    required this.onOpenChildren,
    required this.onOpenNotes,
    required this.onToggleDone,
    required this.onAddChild,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasNote = todo.notes.isNotEmpty;
    final hasChildren = childTaskCount > 0;
    final showActions = hasChildren || hasNote;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isFocused ? AppColors.accentDim.withAlpha(120) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFocused
                ? AppColors.accent
                : todo.done
                    ? AppColors.accent.withAlpha(60)
                    : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: todo.done,
                      onChanged: (_) => onToggleDone(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      todo.name,
                      style: TextStyle(
                        color: todo.done ? AppColors.textDisabled : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: todo.done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  if (hasChildren) ...[
                    const SizedBox(width: 8),
                    ChildTaskCountBadge(count: childTaskCount),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showOptions(context),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textDisabled,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              const Divider(height: 1, color: AppColors.cardBorder),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    if (hasChildren)
                      _ActionButton(
                        icon: Icons.account_tree_outlined,
                        label: 'Child tasks',
                        onTap: onOpenChildren!,
                      ),
                    if (hasNote)
                      _ActionButton(
                        icon: Icons.notes_rounded,
                        label: 'Notes',
                        onTap: onOpenNotes,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    final action = await showNotesActionSheet<String>(
      context,
      actions: const [
        NotesActionSheetItem(
          value: 'addChild',
          label: 'Add Child Task',
          icon: Icons.subdirectory_arrow_right_rounded,
        ),
        NotesActionSheetItem(value: 'duplicate', label: 'Duplicate Task', icon: Icons.copy_rounded),
        NotesActionSheetItem(value: 'rename', label: 'Rename Task', icon: Icons.edit_outlined),
        NotesActionSheetItem(
            value: 'delete',
            label: 'Delete Task',
            icon: Icons.delete_outline_rounded,
            color: AppColors.error),
      ],
    );

    switch (action) {
      case 'addChild':
        await onAddChild();
      case 'duplicate':
        await onDuplicate();
      case 'rename':
        await onRename();
      case 'delete':
        await onDelete();
      case null:
        return;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
