import "package:flutter/material.dart";
import "package:open_git/features/repository/presentation/extensions/repository_path_display_extension.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class RecentRepositoryMenuItem extends StatelessWidget {
  static const double height = 52;

  final String path;
  final bool selected;
  final VoidCallback onTap;

  const RecentRepositoryMenuItem({
    super.key,
    required this.path,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopListRow(
      selected: selected,
      height: height,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.data_object : Icons.folder_outlined,
            size: 16,
            color: selected ? theme.openGit.accent : theme.openGit.textMuted,
          ),
          Gaps.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  path.repositoryDisplayName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.openGit.textPrimary,
                  ),
                ),
                Text(
                  path.repositoryParentPath,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
