import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class BranchGroupHeader extends StatelessWidget {
  final String prefix;
  final int branchCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const BranchGroupHeader({
    super.key,
    required this.prefix,
    required this.branchCount,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Animated arrow icon
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0.0, // 0 = right (→), 0.25 = down (↓)
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_right,
                  size: 18,
                  color: theme.iconTheme.color?.withValues(alpha: 0.7),
                ),
              ),
              Gaps.w8,
              // Folder icon
              Icon(
                Icons.folder_outlined,
                size: 18,
                color: theme.iconTheme.color?.withValues(alpha: 0.6),
              ),
              Gaps.w8,
              // Prefix name
              Expanded(
                child: Text(
                  prefix,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Branch count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$branchCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
