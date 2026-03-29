import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/models/notes_workspace_view_state.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';

class MobileListsView extends StatelessWidget {
  const MobileListsView({
    required this.searchController,
    required this.searchQuery,
    required this.isLoading,
    required this.fileItems,
    required this.onOpenWorkspaceMenu,
    required this.onCreateList,
    required this.onRefresh,
    required this.onOpenFile,
    required this.onRefreshFile,
    required this.onCreateCategory,
    required this.onCloseFile,
    required this.onRenameFile,
    required this.onDuplicateFile,
    required this.onDeleteFile,
    required this.onClearSearch,
    required this.speech,
    super.key,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final bool isLoading;
  final List<DesktopWorkspaceFileItem> fileItems;
  final VoidCallback onOpenWorkspaceMenu;
  final VoidCallback onCreateList;
  final Future<void> Function() onRefresh;
  final ValueChanged<DesktopWorkspaceFileItem> onOpenFile;
  final ValueChanged<DesktopWorkspaceFileItem> onRefreshFile;
  final ValueChanged<DesktopWorkspaceFileItem> onCreateCategory;
  final ValueChanged<DesktopWorkspaceFileItem> onCloseFile;
  final ValueChanged<DesktopWorkspaceFileItem> onRenameFile;
  final ValueChanged<DesktopWorkspaceFileItem> onDuplicateFile;
  final ValueChanged<DesktopWorkspaceFileItem> onDeleteFile;
  final VoidCallback onClearSearch;
  final SpeechController speech;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: const SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 8, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEMORY NOTES',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'My Lists',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 112,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: onOpenWorkspaceMenu,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateList,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          _MobileSearchBar(
            controller: searchController,
            searchQuery: searchQuery,
            onClear: onClearSearch,
            speech: speech,
          ),
          Expanded(
            child: isLoading && fileItems.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : fileItems.isEmpty
                    ? _MobileEmptyState(query: searchQuery)
                    : RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surface,
                        onRefresh: onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: fileItems.length,
                          itemBuilder: (context, index) {
                            final item = fileItems[index];
                            return _MobileFileCard(
                              item: item,
                              onTap: () => onOpenFile(item),
                              onRefresh: () => onRefreshFile(item),
                              onCreateCategory: () => onCreateCategory(item),
                              onClose: () => onCloseFile(item),
                              onRename: () => onRenameFile(item),
                              onDuplicate: () => onDuplicateFile(item),
                              onDelete: () => onDeleteFile(item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MobileSearchBar extends StatelessWidget {
  const _MobileSearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onClear,
    required this.speech,
  });

  final TextEditingController controller;
  final String searchQuery;
  final VoidCallback onClear;
  final SpeechController speech;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search lists...',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search_rounded, color: AppColors.textDisabled, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpeechMicButton(
                controller: controller,
                speech: speech,
                appendToExistingText: false,
                onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                ),
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textDisabled, size: 18),
                  onPressed: onClear,
                ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _MobileEmptyState extends StatelessWidget {
  const _MobileEmptyState({
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.isNotEmpty) {
      return Center(
        child: Text(
          'No lists found for "$query"',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textDisabled),
          SizedBox(height: 16),
          Text(
            'No lists yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to create your first list',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MobileFileCard extends StatelessWidget {
  const _MobileFileCard({
    required this.item,
    required this.onTap,
    required this.onRefresh,
    required this.onCreateCategory,
    required this.onClose,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final DesktopWorkspaceFileItem item;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onCreateCategory;
  final VoidCallback onClose;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final file = item.file;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isOpen
                            ? '${item.categoryCount} categories · Open'
                            : '${item.categoryCount} categories',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_MobileFileAction>(
                  tooltip: 'List actions',
                  icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (action) {
                    switch (action) {
                      case _MobileFileAction.close:
                        onClose();
                      case _MobileFileAction.refresh:
                        onRefresh();
                      case _MobileFileAction.newCategory:
                        onCreateCategory();
                      case _MobileFileAction.rename:
                        onRename();
                      case _MobileFileAction.duplicate:
                        onDuplicate();
                      case _MobileFileAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (item.isOpen)
                      const PopupMenuItem<_MobileFileAction>(
                        value: _MobileFileAction.close,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.close_rounded),
                          title: Text('Close List'),
                        ),
                      ),
                    const PopupMenuItem<_MobileFileAction>(
                      value: _MobileFileAction.refresh,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.refresh_rounded),
                        title: Text('Refresh List'),
                      ),
                    ),
                    const PopupMenuItem<_MobileFileAction>(
                      value: _MobileFileAction.newCategory,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.create_new_folder_outlined),
                        title: Text('New Category'),
                      ),
                    ),
                    const PopupMenuItem<_MobileFileAction>(
                      value: _MobileFileAction.rename,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Rename List'),
                      ),
                    ),
                    const PopupMenuItem<_MobileFileAction>(
                      value: _MobileFileAction.duplicate,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.copy_rounded),
                        title: Text('Duplicate List'),
                      ),
                    ),
                    const PopupMenuItem<_MobileFileAction>(
                      value: _MobileFileAction.delete,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        title: Text(
                          'Delete List',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MobileFileAction {
  close,
  refresh,
  newCategory,
  rename,
  duplicate,
  delete,
}
