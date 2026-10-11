import 'package:memory_notes/core/presentation/connection_banner.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_sort_order.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_view_state.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/notes/presentation/dialogs/notes_dialogs.dart';
import 'package:memory_notes/features/notes/presentation/mobile/mobile_lists_view.dart';
import 'package:memory_notes/features/notes/presentation/note_detail_screen.dart';
import 'package:memory_notes/features/notes/presentation/workspace/file_sidebar.dart';
import 'package:memory_notes/features/notes/presentation/workspace/notes_workspace_panel.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_drilldown.dart';
import 'package:memory_notes/features/notes/presentation/workspace/todo_notes_pane.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage(name: 'NotesListRoute')
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({
    required this.notesWorkspace,
    required this.todoFiles,
    required this.todos,
    required this.notesListActions,
    required this.noteDetailActions,
    required this.notesMobile,
    required this.noteEditActions,
    required this.speech,
    super.key,
  });
  final NotesWorkspaceStore notesWorkspace;
  final TodoFileController todoFiles;
  final TodoController todos;
  final NotesListActions notesListActions;
  final NoteDetailActions noteDetailActions;
  final NotesMobileStore notesMobile;
  final NoteEditActions noteEditActions;
  final SpeechController speech;

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

enum _CategoryAction { duplicate, rename, delete }

enum _WorkspaceAction { openList, reloadAll, mergeDuplicates }

class _NotesListScreenState extends State<NotesListScreen> {
  static const _desktopBreakpoint = 700.0;
  static const _desktopSidebarMinWidth = 240.0;
  static const _desktopSidebarMaxWidth = 640.0;
  static const _desktopCategoryRailMinWidth = 220.0;
  static const _desktopCategoryRailMaxWidth = 560.0;
  static const _desktopTodoDrilldownMaxWidth = 800.0;

  final _desktopSidebarScrollController = ScrollController();
  final _desktopWorkspaceScrollController = ScrollController();
  final _mobileSearchController = TextEditingController();
  final _mobileSearchQuery = signal('');
  final _expandedTodoId = signal<int?>(null);
  double _desktopSidebarWidth = DesktopWorkspaceLayout.defaultSidebarWidth;
  double _desktopCategoryRailWidth = DesktopWorkspaceLayout.defaultCategoryRailWidth;
  double _desktopTodoDrilldownWidth = DesktopWorkspaceLayout.defaultTodoDrilldownWidth;
  NotesSortOrder _sortOrder = NotesSortOrder.lastUpdated;
  CategorySortOrder _categorySortOrder = CategorySortOrder.newest;
  TodoSortOrder _todoSortOrder = TodoSortOrder.newest;
  bool _didInitialize = false;
  int? _pendingDesktopRestoreFileId;
  bool _desktopRestoreScheduled = false;
  int? _lastDesktopSelectedFileId;
  int _selectedTodoRevealRequestId = 0;
  int _todoNotesFocusRequestId = 0;
  int _todoListScrollToTopRequestId = 0;

  static const _sortActions = [
    NotesActionSheetItem(value: NotesSortOrder.nameAZ, label: 'Name A to Z'),
    NotesActionSheetItem(value: NotesSortOrder.nameZA, label: 'Name Z to A'),
    NotesActionSheetItem(value: NotesSortOrder.newest, label: 'Newest first'),
    NotesActionSheetItem(value: NotesSortOrder.oldest, label: 'Oldest first'),
    NotesActionSheetItem(value: NotesSortOrder.lastUpdated, label: 'Last updated'),
  ];

  static const _categorySortActions = [
    NotesActionSheetItem(
      value: CategorySortOrder.newest,
      label: 'Categories: Newest first',
      icon: Icons.schedule_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.nameAZ,
      label: 'Categories: Name A to Z',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.nameZA,
      label: 'Categories: Name Z to A',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.todoCount,
      label: 'Categories: Most todos',
      icon: Icons.checklist_rounded,
    ),
  ];

  static const _todoSortActions = [
    NotesActionSheetItem(
      value: TodoSortOrder.newest,
      label: 'Tasks: Newest first',
      icon: Icons.schedule_rounded,
    ),
    NotesActionSheetItem(
      value: TodoSortOrder.nameAZ,
      label: 'Tasks: Name A to Z',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: TodoSortOrder.nameZA,
      label: 'Tasks: Name Z to A',
      icon: Icons.sort_by_alpha_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_loadDesktopWorkspaceLayout());
    _mobileSearchController.addListener(() {
      _mobileSearchQuery.value = _mobileSearchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadDesktopWorkspaceLayout() async {
    final layout = await widget.notesWorkspace.deviceWorkspaceState.getDesktopWorkspaceLayout();
    if (!mounted) return;
    setState(() {
      _desktopSidebarWidth = _clampDesktopPaneWidth(
        layout.sidebarWidth,
        _desktopSidebarMinWidth,
        _desktopSidebarMaxWidth,
      );
      _desktopCategoryRailWidth = _clampDesktopPaneWidth(
        layout.categoryRailWidth,
        _desktopCategoryRailMinWidth,
        _desktopCategoryRailMaxWidth,
      );
      _desktopTodoDrilldownWidth = _clampDesktopPaneWidth(
        layout.todoDrilldownWidth,
        desktopTodoDrilldownMinWidth,
        _desktopTodoDrilldownMaxWidth,
      );
    });
  }

  static double _clampDesktopPaneWidth(double width, double minWidth, double maxWidth) {
    return width.clamp(minWidth, maxWidth).toDouble();
  }

  void _resizeDesktopSidebar(double delta) {
    setState(() {
      _desktopSidebarWidth = _clampDesktopPaneWidth(
        _desktopSidebarWidth + delta,
        _desktopSidebarMinWidth,
        _desktopSidebarMaxWidth,
      );
    });
  }

  void _resizeDesktopCategoryRail(double delta) {
    setState(() {
      _desktopCategoryRailWidth = _clampDesktopPaneWidth(
        _desktopCategoryRailWidth + delta,
        _desktopCategoryRailMinWidth,
        _desktopCategoryRailMaxWidth,
      );
    });
  }

  void _resizeDesktopTodoDrilldown(double delta) {
    setState(() {
      _desktopTodoDrilldownWidth = _clampDesktopPaneWidth(
        _desktopTodoDrilldownWidth + delta,
        desktopTodoDrilldownMinWidth,
        _desktopTodoDrilldownMaxWidth,
      );
    });
  }

  void _resetDesktopSidebarWidth() {
    setState(() => _desktopSidebarWidth = DesktopWorkspaceLayout.defaultSidebarWidth);
    _persistDesktopWorkspaceLayout();
  }

  void _resetDesktopCategoryRailWidth() {
    setState(() => _desktopCategoryRailWidth = DesktopWorkspaceLayout.defaultCategoryRailWidth);
    _persistDesktopWorkspaceLayout();
  }

  void _resetDesktopTodoDrilldownWidth() {
    setState(() => _desktopTodoDrilldownWidth = DesktopWorkspaceLayout.defaultTodoDrilldownWidth);
    _persistDesktopWorkspaceLayout();
  }

  void _persistDesktopWorkspaceLayout() {
    unawaited(
      widget.notesWorkspace.deviceWorkspaceState.saveDesktopWorkspaceLayout(
        DesktopWorkspaceLayout(
          sidebarWidth: _desktopSidebarWidth,
          categoryRailWidth: _desktopCategoryRailWidth,
          todoDrilldownWidth: _desktopTodoDrilldownWidth,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notesWorkspace.initialize();
    });
  }

  @override
  void dispose() {
    _persistCurrentDesktopScrollOffset();
    _desktopSidebarScrollController.dispose();
    _desktopWorkspaceScrollController.dispose();
    _mobileSearchController.dispose();
    super.dispose();
  }

  void _selectTodo({required int fileId, required int categoryId, required List<int> todoPath}) {
    widget.notesWorkspace.selectTodo(fileId: fileId, categoryId: categoryId, todoPath: todoPath);
  }

  void _selectDesktopTodo({
    required int fileId,
    required int categoryId,
    required List<int> todoPath,
  }) {
    _selectTodo(fileId: fileId, categoryId: categoryId, todoPath: todoPath);
    setState(() {
      _selectedTodoRevealRequestId++;
      _todoNotesFocusRequestId++;
    });
  }

  void _selectDesktopCategory({required TodoFile file, required Category category}) {
    widget.notesWorkspace.selectCategory(file: file, category: category);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_desktopWorkspaceScrollController.hasClients) return;
      final position = _desktopWorkspaceScrollController.position;
      final targetOffset = (_desktopSidebarWidth +
              desktopPaneDividerWidth +
              _desktopCategoryRailWidth +
              desktopPaneDividerWidth)
          .clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _desktopWorkspaceScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _toggleDesktopTodo(Todo todo) => widget.notesWorkspace.toggleTodo(todo);

  Future<void> _deleteDesktopTodo(Todo todo, {required List<Todo> todos}) {
    final siblings = widget.notesWorkspace.query.sortTodos(
      todos.where((item) => item.parentTodoId == todo.parentTodoId),
      sortOrder: _todoSortOrder,
    );
    final todoIndex = siblings.indexWhere((item) => item.id == todo.id);
    final nextTodo = todoIndex == -1 || todoIndex + 1 == siblings.length
        ? null
        : siblings[todoIndex + 1];
    return widget.notesWorkspace.deleteTodo(todo, nextTodo: nextTodo);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopWorkspace = _shouldUseDesktopWorkspace(constraints.maxWidth);
        return SignalBuilder(
          dependencies: [
            widget.notesWorkspace.workspace.selection,
            widget.notesWorkspace.workspace.openFileIds,
            widget.todoFiles.todoFiles,
            widget.notesWorkspace.categories.categories,
            widget.notesWorkspace.categories.loadedCategoryFileIds,
            widget.todos.todosByCategory,
            widget.todos.loadedTodoCategoryIds,
            widget.todos.error,
          ],
          builder: (context) {
            widget.notesWorkspace.syncWorkspace();
            return isDesktopWorkspace
                ? _buildDesktopWorkspace(context)
                : _buildMobileLists(context);
          },
        );
      },
    );
  }

  bool _shouldUseDesktopWorkspace(double maxWidth) {
    if (kIsWeb) {
      return maxWidth >= _desktopBreakpoint;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return maxWidth >= _desktopBreakpoint;
    }
  }

  Widget _buildMobileLists(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final controller = widget.todoFiles;
        final query = _mobileSearchQuery.value;
        final workspaceView = widget.notesWorkspace.buildViewState(
          sortOrder: _sortOrder,
          categorySortOrder: _categorySortOrder,
          todoSortOrder: _todoSortOrder,
        );
        List<DesktopWorkspaceFileItem> filterItems(List<DesktopWorkspaceFileItem> items) {
          if (query.isEmpty) return items;
          return items
              .where((item) => item.file.name.toLowerCase().contains(query))
              .toList(growable: false);
        }

        return MobileListsView(
          searchController: _mobileSearchController,
          searchQuery: query,
          isLoading: controller.isLoading.value,
          loadError: controller.error.value,
          fileItems: filterItems(workspaceView.openFileItems),
          onOpenWorkspaceMenu: () => _showWorkspaceMenu(context),
          onCreateList: () => _showCreateListDialog(context),
          onRefresh: controller.load,
          onOpenFile: (item) async {
            final file = item.file;
            final fileId = file.id;
            if (fileId == null) return;
            await widget.notesListActions.openFile(file);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: NoteDetailRoute.name),
                builder: (_) => NoteDetailScreen(
                  fileId: fileId,
                  notesMobile: widget.notesMobile,
                  noteDetailActions: widget.noteDetailActions,
                  noteEditActions: widget.noteEditActions,
                  speech: widget.speech,
                ),
              ),
            );
          },
          onRefreshFile: (item) => widget.notesListActions.reloadList(item.file),
          onCreateCategory: (item) => _showCreateCategoryDialog(context, item.file),
          onCloseFile: (item) => widget.notesListActions.closeFile(item.file),
          onRenameFile: (item) => _showRenameListDialog(context, item.file),
          onDuplicateFile: (item) => _showDuplicateListDialog(context, item.file),
          onDeleteFile: (item) => controller.delete(item.file.id!),
          speech: widget.speech,
          onClearSearch: () {
            _mobileSearchController.clear();
            _mobileSearchQuery.value = '';
          },
        );
      },
    );
  }

  Widget _buildDesktopWorkspace(BuildContext context) {
    if (widget.todoFiles.todoFiles.value.isEmpty && widget.todoFiles.error.value != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: LoadErrorView(
          error: widget.todoFiles.error.value!,
          onRetry: () async {
            widget.notesWorkspace.categories.resetLoadBackoff();
            widget.todos.resetLoadBackoff();
            await widget.notesWorkspace.initialize();
            await widget.notesWorkspace.reloadAllFiles();
          },
        ),
      );
    }
    final viewState = widget.notesWorkspace.buildViewState(
      sortOrder: _sortOrder,
      categorySortOrder: _categorySortOrder,
      todoSortOrder: _todoSortOrder,
    );
    final selectedFile = viewState.selectedFile;
    final selectedCategory = viewState.selectedCategory;
    final activeTodoParentId = _desktopActiveTodoParentId(
      todos: viewState.todos,
      selectedTodo: viewState.selectedTodo,
    );
    final categoryTaskCounts = <int, int>{
      for (final category in viewState.categories)
        if (category.id != null)
          category.id!: widget.notesWorkspace.query.todoCount(
            widget.todos.todosByCategory.value,
            category.id,
          ),
    };
    final topInset = MediaQuery.paddingOf(context).top;

    if (selectedFile?.id != _lastDesktopSelectedFileId) {
      _lastDesktopSelectedFileId = selectedFile?.id;
      _scheduleDesktopScrollRestore(selectedFile?.id);
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (topInset > 0)
            Container(
              height: topInset,
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minWorkspaceWidth =
                    _desktopCategoryRailWidth +
                    desktopPaneDividerWidth +
                    _desktopTodoDrilldownWidth +
                    desktopPaneDividerWidth +
                    desktopTodoNotesPaneMinWidth;
                final minDesktopWidth =
                    _desktopSidebarWidth + desktopPaneDividerWidth + minWorkspaceWidth;
                final contentWidth = constraints.maxWidth < minDesktopWidth
                    ? minDesktopWidth
                    : constraints.maxWidth;
                final workspaceWidth =
                    contentWidth - _desktopSidebarWidth - desktopPaneDividerWidth;

                return NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis != Axis.horizontal) return false;
                    _persistCurrentDesktopScrollOffset();
                    return false;
                  },
                  child: Scrollbar(
                    controller: _desktopWorkspaceScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    notificationPredicate: (notification) =>
                        notification.depth == 0 && notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _desktopWorkspaceScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: contentWidth,
                        child: Row(
                          children: [
                            SizedBox(
                              width: _desktopSidebarWidth,
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: AppColors.navBackground,
                                ),
                                child: Column(
                                  children: [
                                    DesktopSidebarHeader(
                                      onCreateList: () => _showCreateListDialog(context),
                                      onOpenMenu: () => _showWorkspaceMenu(context),
                                    ),
                                    Expanded(
                                      child: viewState.openFileItems.isEmpty
                                          ? const DesktopEmptySidebar()
                                          : Scrollbar(
                                              controller: _desktopSidebarScrollController,
                                              thumbVisibility: true,
                                              trackVisibility: true,
                                              scrollbarOrientation: ScrollbarOrientation.right,
                                              child: ListView(
                                                controller: _desktopSidebarScrollController,
                                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                children: viewState.openFileItems
                                                    .map(
                                                      (item) =>
                                                          _buildDesktopFileTile(context, item),
                                                    )
                                                    .toList(growable: false),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DesktopPaneDivider(
                              key: const ValueKey('desktop-sidebar-divider'),
                              onResize: _resizeDesktopSidebar,
                              onResizeEnd: _persistDesktopWorkspaceLayout,
                              onReset: _resetDesktopSidebarWidth,
                            ),
                            SizedBox(
                              width: workspaceWidth,
                              child: selectedFile == null
                                  ? const DesktopWorkspaceEmptyState()
                                  : DesktopNotesPanel(
                                      file: selectedFile,
                                      category: selectedCategory,
                                      categories: viewState.categories,
                                      categoryTaskCounts: categoryTaskCounts,
                                      todos: viewState.todos,
                                      todoLoadError: widget.todos.error.value,
                                      todoSortOrder: _todoSortOrder,
                                      selectedTodo: viewState.selectedTodo,
                                      selectedTodoPath: viewState.selectedTodoPath,
                                      selectedTodoRevealRequestId: _selectedTodoRevealRequestId,
                                      todoNotesFocusRequestId: _todoNotesFocusRequestId,
                                      todoListScrollToTopRequestId: _todoListScrollToTopRequestId,
                                      expandedTodoId: _expandedTodoId,
                                      categoryRailWidth: _desktopCategoryRailWidth,
                                      todoDrilldownWidth: _desktopTodoDrilldownWidth,
                                      speech: widget.speech,
                                      onCreateCategory: () =>
                                          _showCreateCategoryDialog(context, selectedFile),
                                      onCreateTodo: selectedCategory == null
                                          ? null
                                          : () => _showCreateTodoDialog(
                                              context,
                                              fileId: selectedFile.id!,
                                              categoryId: selectedCategory.id!,
                                              parentTodoId: activeTodoParentId,
                                            ),
                                      onCreateChildTodo: (todo) => _showCreateTodoDialog(
                                        context,
                                        fileId: selectedFile.id!,
                                        categoryId: selectedCategory!.id!,
                                        parentTodoId: todo.id,
                                        isChildTask: true,
                                      ),
                                      onSelectCategory: (category) => _selectDesktopCategory(
                                        file: selectedFile,
                                        category: category,
                                      ),
                                      onSelectTodo: (todoPath) => _selectDesktopTodo(
                                        fileId: selectedFile.id!,
                                        categoryId: selectedCategory!.id!,
                                        todoPath: todoPath,
                                      ),
                                      onTodoDuplicate: (todo) =>
                                          _showCopyTodoDialog(context, todo),
                                      onTodoRename: (todo) => _showRenameTodoDialog(context, todo),
                                      onTodoDelete: (todo) => _deleteDesktopTodo(
                                        todo,
                                        todos: viewState.todos,
                                      ),
                                      onTodoToggle: _toggleDesktopTodo,
                                      onSaveTodoNotes: _saveTodoNotes,
                                      onCategorySortMenu: () => _showCategorySortMenu(context),
                                      onTodoSortMenu: () => _showTodoSortMenu(context),
                                      onCategoryRailResize: _resizeDesktopCategoryRail,
                                      onCategoryRailResizeEnd: _persistDesktopWorkspaceLayout,
                                      onCategoryRailReset: _resetDesktopCategoryRailWidth,
                                      onTodoDrilldownResize: _resizeDesktopTodoDrilldown,
                                      onTodoDrilldownResizeEnd: _persistDesktopWorkspaceLayout,
                                      onTodoDrilldownReset: _resetDesktopTodoDrilldownWidth,
                                      onCategoryActions: selectedCategory == null
                                          ? null
                                          : () => _showCategoryActions(
                                              context,
                                              category: selectedCategory,
                                              file: selectedFile,
                                            ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'New List',
      hintText: 'List name',
      confirmLabel: 'Create',
      speech: widget.speech,
      validator: _validateListName,
    );
    if (name == null) return;
    await widget.notesListActions.createList(name);
  }

  Future<void> _showCreateCategoryDialog(BuildContext context, TodoFile file) async {
    if (file.id == null) return;
    final name = await showNotesTextPromptDialog(
      context,
      title: 'New Category',
      hintText: 'Category name',
      confirmLabel: 'Create',
      speech: widget.speech,
    );
    if (name == null) return;
    await widget.notesListActions.createCategory(file, name);
  }

  Future<void> _showCreateTodoDialog(
    BuildContext context, {
    required int fileId,
    required int categoryId,
    int? parentTodoId,
    bool isChildTask = false,
  }) async {
    final text = await showNotesTextPromptDialog(
      context,
      title: isChildTask ? 'New Child Task' : 'New Task',
      hintText: isChildTask ? 'Child task name' : 'Task name',
      confirmLabel: 'Create',
      speech: widget.speech,
    );
    if (text == null) return;
    final created = await widget.notesWorkspace.addTodo(
      fileId: fileId,
      categoryId: categoryId,
      text: text,
      parentTodoId: parentTodoId,
    );
    if (created != null && mounted) {
      setState(() => _todoListScrollToTopRequestId++);
    }
  }

  int? _desktopActiveTodoParentId({required List<Todo> todos, required Todo? selectedTodo}) {
    if (selectedTodo?.id == null) {
      return null;
    }
    return selectedTodo!.parentTodoId;
  }

  Future<void> _showRenameListDialog(BuildContext context, TodoFile file) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'Rename List',
      hintText: 'List name',
      confirmLabel: 'Rename',
      initialValue: file.name,
      speech: widget.speech,
      validator: (value) => _validateListName(value, excludingId: file.id),
    );
    if (name == null || name == file.name) return;
    await widget.notesListActions.renameList(file, name);
  }

  Future<void> _showDuplicateListDialog(BuildContext context, TodoFile file) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'Duplicate List',
      hintText: 'List name',
      confirmLabel: 'Duplicate',
      initialValue: '${file.name} (Copy)',
      speech: widget.speech,
      validator: _validateListName,
    );
    if (name == null) return;
    await widget.notesListActions.duplicateList(file: file, name: name);
  }

  String? _validateListName(String value, {int? excludingId}) {
    final duplicate = widget.todoFiles.findByName(value, excludingId: excludingId);
    if (duplicate != null) {
      return 'A list named "${duplicate.name}" already exists.';
    }
    return null;
  }

  Future<void> _mergeDuplicateLists({int? preferredFileId}) async {
    final result = await widget.notesListActions.mergeDuplicateLists(
      preferredFileId: preferredFileId,
    );
    widget.notesWorkspace.syncWorkspace();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!result.didMerge) {
      messenger.showSnackBar(const SnackBar(content: Text('No duplicate lists found to merge.')));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Merged ${result.mergedListCount} duplicate list'
          '${result.mergedListCount == 1 ? '' : 's'} into "${result.primaryFile?.name ?? 'the primary list'}".',
        ),
      ),
    );
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
    await widget.notesListActions.renameTodo(todo, name);
  }

  Future<void> _showCopyTodoDialog(BuildContext context, Todo todo) async {
    final destination = await showCopyNoteDestinationDialog(
      context,
      sourceTodo: todo,
      files: widget.todoFiles.todoFiles.value
          .where((file) => file.id != null)
          .toList(growable: false),
      loadCategories: (fileId) async {
        widget.notesWorkspace.categories.resetLoadBackoff();
        await widget.notesWorkspace.categories.loadCategories(fileId);
        if (widget.notesWorkspace.categories.error.value != null) {
          throw StateError(widget.notesWorkspace.categories.error.value!);
        }
        return widget.notesWorkspace.query.categoriesForFile(
          widget.notesWorkspace.categories.categories.value,
          fileId,
        );
      },
      loadTodos: (categoryId) async {
        widget.todos.resetLoadBackoff();
        if (!await widget.todos.loadTodos(categoryId)) {
          throw StateError(widget.todos.error.value ?? 'Could not load tasks.');
        }
        return widget.notesWorkspace.query.todosForCategory(
          widget.todos.todosByCategory.value,
          categoryId,
        );
      },
    );
    if (destination == null) return;
    await widget.notesListActions.copyTodo(
      todo: todo,
      targetFileId: destination.fileId,
      targetCategoryId: destination.categoryId,
      targetParentTodoId: destination.parentTodoId,
    );
  }

  Future<void> _showOpenListDialog(BuildContext context) async {
    final closedItems = widget.notesWorkspace.buildClosedFileItems(sortOrder: _sortOrder);
    final selectedFile = await showNotesSelectionDialog<TodoFile>(
      context,
      title: 'Open List',
      emptyMessage: 'All lists are already open.',
      searchHintText: 'Search lists...',
      items: closedItems
          .map(
            (item) => NotesSelectionDialogItem<TodoFile>(
              value: item.file,
              label: item.file.name,
              subtitle: '${item.categoryCount} categories',
            ),
          )
          .toList(growable: false),
    );
    if (selectedFile == null) return;
    await widget.notesListActions.openFile(selectedFile);
  }

  Future<void> _saveTodoNotes(Todo todo, String notes) async {
    await widget.notesListActions.saveTodoNotes(todo: todo, notes: notes);
  }

  Future<void> _showCategoryActions(
    BuildContext context, {
    required Category category,
    required TodoFile file,
  }) async {
    final action = await showNotesActionSheet<_CategoryAction>(
      context,
      actions: const [
        NotesActionSheetItem(
          value: _CategoryAction.duplicate,
          label: 'Duplicate Category',
          icon: Icons.copy_rounded,
        ),
        NotesActionSheetItem(
          value: _CategoryAction.rename,
          label: 'Rename Category',
          icon: Icons.edit_outlined,
        ),
        NotesActionSheetItem(
          value: _CategoryAction.delete,
          label: 'Delete Category',
          icon: Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ],
    );

    if (action == _CategoryAction.rename) {
      if (!context.mounted) return;
      final name = await showNotesTextPromptDialog(
        context,
        title: 'Rename Category',
        hintText: 'Category name',
        confirmLabel: 'Rename',
        initialValue: category.name,
        speech: widget.speech,
      );
      if (name != null && name != category.name) {
        await widget.notesListActions.renameCategory(category, name);
      }
    }

    if (action == _CategoryAction.duplicate) {
      if (!context.mounted) return;
      final name = await showNotesTextPromptDialog(
        context,
        title: 'Duplicate Category',
        hintText: 'Category name',
        confirmLabel: 'Duplicate',
        initialValue: '${category.name} (Copy)',
        speech: widget.speech,
      );
      if (name != null) {
        await widget.notesListActions.duplicateCategory(category: category, name: name);
      }
    }

    if (action == _CategoryAction.delete) {
      await widget.notesListActions.deleteCategory(category: category, file: file);
    }
  }

  Widget _buildDesktopFileTile(BuildContext context, DesktopWorkspaceFileItem item) {
    final file = item.file;
    return DesktopTreeFileTile(
      file: file,
      categoryCount: item.categoryCount,
      isSelected: item.isSelected,
      isOpen: item.isOpen,
      onTap: () async {
        _persistCurrentDesktopScrollOffset();
        await widget.notesWorkspace.selectFile(file, autoSelectFirstCategory: false);
      },
      onToggleOpen: () => item.isOpen
          ? widget.notesListActions.closeFile(file)
          : widget.notesListActions.openFile(file),
      onRefresh: () => widget.notesListActions.reloadList(file),
      onCreateCategory: () async {
        _persistCurrentDesktopScrollOffset();
        await widget.notesWorkspace.selectFile(file, autoSelectFirstCategory: false);
        if (context.mounted) {
          await _showCreateCategoryDialog(context, file);
        }
      },
      onRename: () => _showRenameListDialog(context, file),
      onDuplicate: () => _showDuplicateListDialog(context, file),
      onDelete: () => widget.todoFiles.delete(file.id!),
    );
  }

  Future<void> _showWorkspaceMenu(BuildContext context) async {
    final canOpenList = widget.notesWorkspace
        .buildClosedFileItems(sortOrder: _sortOrder)
        .isNotEmpty;

    final action = await showNotesActionSheet<Object>(
      context,
      actions: [
        if (canOpenList)
          const NotesActionSheetItem<Object>(
            value: _WorkspaceAction.openList,
            label: 'Open List',
            icon: Icons.folder_open_rounded,
          ),
        const NotesActionSheetItem<Object>(
          value: _WorkspaceAction.reloadAll,
          label: 'Reload All',
          icon: Icons.refresh_rounded,
        ),
        const NotesActionSheetItem<Object>(
          value: _WorkspaceAction.mergeDuplicates,
          label: 'Merge Duplicate Lists',
          icon: Icons.merge_type_rounded,
        ),
        ..._sortActions.map(
          (action) => NotesActionSheetItem<Object>(
            value: action.value,
            label: action.label,
            icon: action.icon,
            color: action.color,
          ),
        ),
      ],
    );

    if (action == _WorkspaceAction.openList) {
      if (!context.mounted) return;
      await _showOpenListDialog(context);
      return;
    }

    if (action == _WorkspaceAction.reloadAll) {
      await widget.notesListActions.reloadAll();
      return;
    }

    if (action == _WorkspaceAction.mergeDuplicates) {
      await _mergeDuplicateLists();
      return;
    }

    if (action case final NotesSortOrder order) {
      setState(() => _sortOrder = order);
      return;
    }
  }

  Future<void> _showCategorySortMenu(BuildContext context) async {
    final action = await showNotesActionSheet<CategorySortOrder>(
      context,
      actions: _categorySortActions,
    );
    if (action != null) {
      setState(() => _categorySortOrder = action);
    }
  }

  Future<void> _showTodoSortMenu(BuildContext context) async {
    final action = await showNotesActionSheet<TodoSortOrder>(context, actions: _todoSortActions);
    if (action != null) {
      setState(() => _todoSortOrder = action);
    }
  }

  void _scheduleDesktopScrollRestore(int? fileId) {
    if (fileId == null) {
      _pendingDesktopRestoreFileId = null;
      return;
    }
    _pendingDesktopRestoreFileId = fileId;
    if (_desktopRestoreScheduled) return;
    _desktopRestoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _desktopRestoreScheduled = false;
      _applyPendingDesktopScrollRestore();
    });
  }

  void _applyPendingDesktopScrollRestore() {
    final fileId = _pendingDesktopRestoreFileId;
    if (!mounted || fileId == null || !_desktopWorkspaceScrollController.hasClients) return;
    if (widget.notesWorkspace.workspace.selectedFileId != fileId) {
      _pendingDesktopRestoreFileId = null;
      return;
    }

    final position = _desktopWorkspaceScrollController.position;
    final restoredOffset = widget.notesWorkspace.desktopScrollOffsetForFile(fileId);
    final targetOffset = restoredOffset.clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((_desktopWorkspaceScrollController.offset - targetOffset).abs() > 1) {
      _desktopWorkspaceScrollController.jumpTo(targetOffset);
    }

    if (restoredOffset <= position.maxScrollExtent + 1) {
      _pendingDesktopRestoreFileId = null;
      return;
    }

    _scheduleDesktopScrollRestore(fileId);
  }

  void _persistCurrentDesktopScrollOffset() {
    final selectedFileId = widget.notesWorkspace.workspace.selectedFileId;
    if (selectedFileId == null || !_desktopWorkspaceScrollController.hasClients) return;
    final currentOffset = _desktopWorkspaceScrollController.offset;
    final rememberedOffset = widget.notesWorkspace.desktopScrollOffsetForFile(selectedFileId);
    final isTemporarySidebarReveal =
        currentOffset <= _desktopSidebarWidth + desktopPaneDividerWidth &&
        rememberedOffset > _desktopSidebarWidth + desktopPaneDividerWidth;
    if (isTemporarySidebarReveal) {
      return;
    }
    widget.notesWorkspace.saveDesktopScrollOffset(fileId: selectedFileId, offset: currentOffset);
  }
}
