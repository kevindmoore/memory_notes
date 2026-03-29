import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/mobile_note_detail_view_state.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/notes/presentation/dialogs/notes_dialogs.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage(name: 'NoteDetailRoute')
class NoteDetailScreen extends StatefulWidget {
  final int fileId;
  final NotesMobileStore notesMobile;
  final NoteDetailActions noteDetailActions;
  final NoteEditActions noteEditActions;
  final SpeechController speech;

  const NoteDetailScreen({
    @PathParam('fileId') required this.fileId,
    required this.notesMobile,
    required this.noteDetailActions,
    required this.noteEditActions,
    required this.speech,
    super.key,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final _todoFileId = widget.fileId;
  final _searchController = TextEditingController();
  final _searchQuery = signal('');
  CategorySortOrder _categorySortOrder = CategorySortOrder.newest;
  bool _didLoad = false;

  static const _listMenuActions = [
    NotesActionSheetItem(
      value: 'rename',
      label: 'Rename List',
      icon: Icons.drive_file_rename_outline_rounded,
    ),
    NotesActionSheetItem(
      value: 'duplicate',
      label: 'Duplicate List',
      icon: Icons.copy_rounded,
    ),
    NotesActionSheetItem(
      value: 'reload',
      label: 'Reload',
      icon: Icons.refresh_rounded,
    ),
    NotesActionSheetItem(
      value: 'delete',
      label: 'Delete List',
      icon: Icons.delete_outline_rounded,
      color: AppColors.error,
    ),
  ];

  static const _categorySortActions = [
    NotesActionSheetItem(
      value: CategorySortOrder.newest,
      label: 'Sort Categories: Newest first',
      icon: Icons.schedule_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.nameAZ,
      label: 'Sort Categories: Name A to Z',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.nameZA,
      label: 'Sort Categories: Name Z to A',
      icon: Icons.sort_by_alpha_rounded,
    ),
    NotesActionSheetItem(
      value: CategorySortOrder.todoCount,
      label: 'Sort Categories: Most todos',
      icon: Icons.checklist_rounded,
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
      widget.notesMobile.loadFile(_todoFileId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.maybePop(),
        ),
        titleSpacing: 8,
        title: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROJECT MEMORY',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Watch((context) {
                  return Text(
                    widget.notesMobile
                        .buildNoteDetailViewState(
                          fileId: _todoFileId,
                          searchQuery: _searchQuery.value,
                          categorySortOrder: _categorySortOrder,
                        )
                        .fileName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        toolbarHeight: 108,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: () => _showListMenu(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategoryDialog(context),
        tooltip: 'New Category',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryHeader(),
          Expanded(
            child: Watch((context) {
              final viewState = widget.notesMobile.buildNoteDetailViewState(
                fileId: _todoFileId,
                searchQuery: _searchQuery.value,
                categorySortOrder: _categorySortOrder,
              );
              if (viewState.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              if (viewState.categories.isEmpty) return _buildEmpty();
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: viewState.categories.length,
                itemBuilder: (context, i) => _CategoryCard(
                  notesMobile: widget.notesMobile,
                  noteEditActions: widget.noteEditActions,
                  item: viewState.categories[i],
                  fileId: _todoFileId,
                  speech: widget.speech,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search categories and tasks...',
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

  Widget _buildCategoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Categories',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showCategorySortMenu(context),
            icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary),
            tooltip: 'Sort categories',
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.create_new_folder_rounded, size: 32, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          const Text(
            'No categories yet',
            style:
                TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add your first category',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateCategoryDialog(BuildContext context) async {
    final name = await showNotesTextPromptDialog(
      context,
      title: 'New Category',
      hintText: 'Category name',
      confirmLabel: 'Create',
      speech: widget.speech,
    );
    if (name == null) return;
    await widget.noteDetailActions.createCategory(
      fileId: _todoFileId,
      name: name,
    );
  }

  Future<void> _showListMenu(BuildContext context) async {
    final file = widget.noteDetailActions.findFileById(_todoFileId);
    if (file == null) return;

    final action = await showNotesActionSheet<Object>(
      context,
      actions: _listMenuActions,
    );

    switch (action) {
      case 'rename':
        if (!context.mounted) return;
        final name = await showNotesTextPromptDialog(
          context,
          title: 'Rename List',
          hintText: 'List name',
          confirmLabel: 'Rename',
          initialValue: file.name,
          speech: widget.speech,
        );
        if (name != null && name != file.name) {
          await widget.noteDetailActions.renameList(
            file: file,
            name: name,
          );
        }
      case 'duplicate':
        if (!context.mounted) return;
        final duplicateName = await showNotesTextPromptDialog(
          context,
          title: 'Duplicate List',
          hintText: 'List name',
          confirmLabel: 'Duplicate',
          initialValue: '${file.name} (Copy)',
          speech: widget.speech,
        );
        if (duplicateName == null) return;
        final duplicated = await widget.noteDetailActions.duplicateList(
          file,
          name: duplicateName,
        );
        if (duplicated != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated as "${duplicated.name}"'),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      case 'reload':
        await widget.noteDetailActions.reloadList(fileId: _todoFileId);
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await showNotesConfirmDialog(
          context,
          title: 'Delete List?',
          message: 'This will permanently delete "${file.name}" and all its categories.',
          confirmLabel: 'Delete',
        );
        if (confirmed) {
          await widget.noteDetailActions.deleteList(fileId: file.id!);
          if (context.mounted) {
            context.maybePop();
          }
        }
      case null:
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
}

// ---------------------------------------------------------------------------
// Category card with per-row ⋯ button opening a bottom sheet
// ---------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  final NotesMobileStore notesMobile;
  final NoteEditActions noteEditActions;
  final MobileNoteDetailCategoryItem item;
  final int fileId;
  final SpeechController speech;

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

  const _CategoryCard({
    required this.notesMobile,
    required this.noteEditActions,
    required this.item,
    required this.fileId,
    required this.speech,
  });

  @override
  Widget build(BuildContext context) {
    final category = item.category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.pushRoute(
            NoteEditRoute(
              fileId: fileId,
              categoryId: category.id!,
              notesMobile: notesMobile,
              noteEditActions: noteEditActions,
              speech: speech,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.accentDim,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.folder_rounded, color: AppColors.accent, size: 25),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.topLevelTodoCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.badge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.topLevelTodoCount}',
                        style: const TextStyle(
                          color: AppColors.badgeText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  // Per-row options button
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
          ),
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    final category = item.category;
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
          speech: speech,
        );
        if (name != null && name != category.name) {
          await noteEditActions.renameCategory(
            category: category,
            name: name,
          );
        }
      case 'duplicate':
        if (!context.mounted) return;
        final duplicateName = await showNotesTextPromptDialog(
          context,
          title: 'Duplicate Category',
          hintText: 'Category name',
          confirmLabel: 'Duplicate',
          initialValue: '${category.name} (Copy)',
          speech: speech,
        );
        if (duplicateName == null) return;
        await noteEditActions.duplicateCategory(
          category: category,
          name: duplicateName,
        );
      case 'delete':
        await noteEditActions.deleteCategory(
          categoryId: category.id!,
        );
      case null:
        return;
    }
  }
}
