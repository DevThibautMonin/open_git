import "dart:math" as math;

import "package:flutter/material.dart";
import "package:open_git/features/repository/presentation/ui/recent_repository_menu_item.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class RecentRepositoriesMenu extends StatelessWidget {
  final String currentRepositoryPath;
  final List<String> recentRepositoryPaths;
  final ValueChanged<String> onRepositorySelected;
  final VoidCallback onOpenRepository;

  const RecentRepositoriesMenu({
    super.key,
    required this.currentRepositoryPath,
    required this.recentRepositoryPaths,
    required this.onRepositorySelected,
    required this.onOpenRepository,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentRepositoryPaths.isEmpty) {
      return SizedBox(
        width: 360,
        child: DesktopListRow(
          margin: EdgeInsets.zero,
          onTap: onOpenRepository,
          child: Row(
            children: [
              Icon(
                Icons.folder_open,
                size: 16,
                color: theme.openGit.textMuted,
              ),
              Gaps.w8,
              Text(
                "Open repository",
                style: theme.openGitBody.copyWith(
                  color: theme.openGit.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visibleCount = math.min(recentRepositoryPaths.length, 5);

    return SizedBox(
      width: 420,
      height: RecentRepositoryMenuItem.height * visibleCount,
      child: SingleChildScrollView(
        child: Column(
          children: recentRepositoryPaths
              .map((path) {
                return RecentRepositoryMenuItem(
                  path: path,
                  selected: path == currentRepositoryPath,
                  onTap: () {
                    onRepositorySelected(path);
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
