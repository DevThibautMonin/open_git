import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart';
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

    return DesktopListRow(
      onTap: onToggle,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          AnimatedRotation(
            turns: isExpanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.arrow_right,
              size: 18,
              color: theme.openGit.textMuted,
            ),
          ),
          Gaps.w8,
          Icon(
            Icons.folder_outlined,
            size: 16,
            color: theme.openGit.textMuted,
          ),
          Gaps.w8,
          Expanded(
            child: Text(
              prefix,
              style: theme.openGitBody.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.openGit.panelAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.openGit.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              child: Text(
                '$branchCount',
                style: theme.openGitCaption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
