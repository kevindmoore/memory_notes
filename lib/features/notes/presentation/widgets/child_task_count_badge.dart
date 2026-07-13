import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';

class ChildTaskCountBadge extends StatelessWidget {
  const ChildTaskCountBadge({
    super.key,
    required this.count,
    this.isSelected = false,
  });

  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final foregroundColor = isSelected ? Colors.white : AppColors.badgeText;
    return Semantics(
      label: '$count child ${count == 1 ? 'task' : 'tasks'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedSurfaceStrong : AppColors.badge,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_tree_outlined, size: 13, color: foregroundColor),
              const SizedBox(width: 3),
              Text(
                '$count',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
