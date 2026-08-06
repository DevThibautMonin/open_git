import "package:flutter/material.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class WorkingDirectorySectionEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const WorkingDirectorySectionEmptyState({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.openGit.textMuted,
          ),
          Gaps.w8,
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.openGitCaption.copyWith(
              color: theme.openGit.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
