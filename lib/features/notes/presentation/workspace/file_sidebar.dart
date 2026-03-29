import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';

class DesktopSidebarHeader extends StatelessWidget {
  const DesktopSidebarHeader({
    super.key,
    required this.onCreateList,
    required this.onOpenMenu,
  });

  final VoidCallback onCreateList;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MEMORY NOTES',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Workspace',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenMenu,
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: onCreateList,
                icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DesktopEmptySidebar extends StatelessWidget {
  const DesktopEmptySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Open a list from the menu, or create a new one to start building your workspace.',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class DesktopTreeFileTile extends StatelessWidget {
  const DesktopTreeFileTile({
    super.key,
    required this.file,
    required this.categoryCount,
    required this.isSelected,
    required this.isOpen,
    required this.onTap,
    required this.onToggleOpen,
    required this.onRefresh,
    required this.onCreateCategory,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final TodoFile file;
  final int categoryCount;
  final bool isSelected;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onToggleOpen;
  final VoidCallback onRefresh;
  final VoidCallback onCreateCategory;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.selectedSurface : AppColors.surfaceVariant.withAlpha(120),
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected ? AppColors.selectedBorder : AppColors.cardBorder,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x403E67FF),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 4,
                height: 48,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColors.selectedBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            Expanded(
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isSelected ? 14 : 18, 16, 4, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.selectedSurfaceStrong : AppColors.accentDim,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOpen
                                  ? '$categoryCount categories · Open'
                                  : '$categoryCount categories',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              color: AppColors.surface,
              icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textDisabled),
              onSelected: (value) {
                if (value == 'toggleOpen') {
                  onToggleOpen();
                  return;
                }
                if (value == 'refresh') return onRefresh();
                if (value == 'newCategory') return onCreateCategory();
                if (value == 'rename') return onRename();
                if (value == 'duplicate') return onDuplicate();
                if (value == 'delete') return onDelete();
              },
              itemBuilder: (context) => [
                if (isOpen)
                  const PopupMenuItem(
                    value: 'toggleOpen',
                    child: Text('Close List'),
                  ),
                const PopupMenuItem(value: 'refresh', child: Text('Refresh List')),
                const PopupMenuItem(value: 'newCategory', child: Text('New Category')),
                const PopupMenuItem(value: 'rename', child: Text('Rename List')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate List')),
                const PopupMenuItem(value: 'delete', child: Text('Delete List')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopSidebarSectionLabel extends StatelessWidget {
  const DesktopSidebarSectionLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
