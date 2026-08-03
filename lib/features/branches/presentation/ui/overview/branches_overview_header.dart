import "package:flutter/material.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class BranchesOverviewHeader extends StatelessWidget {
  final int branchCount;
  final int unmergedCount;
  final int remoteWorkCount;

  const BranchesOverviewHeader({
    super.key,
    required this.branchCount,
    required this.unmergedCount,
    required this.remoteWorkCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.account_tree_outlined,
          size: 16,
          color: theme.openGit.accent,
        ),
        Gaps.w8,
        Text(
          "Branches overview",
          style: theme.openGitTitle,
        ),
        Gaps.w12,
        Text(
          "$branchCount local",
          overflow: TextOverflow.ellipsis,
          style: theme.openGitCaption,
        ),
        Gaps.w12,
        Text(
          "$unmergedCount not merged",
          overflow: TextOverflow.ellipsis,
          style: theme.openGitCaption.copyWith(
            color: unmergedCount > 0
                ? theme.openGit.accent
                : theme.openGit.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        Gaps.w12,
        Text(
          "$remoteWorkCount remote changes",
          overflow: TextOverflow.ellipsis,
          style: theme.openGitCaption.copyWith(
            color: remoteWorkCount > 0
                ? theme.openGit.warning
                : theme.openGit.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
