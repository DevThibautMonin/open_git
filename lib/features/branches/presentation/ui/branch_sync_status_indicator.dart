import "package:flutter/material.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class BranchSyncStatusIndicator extends StatelessWidget {
  final int commitsAhead;
  final int commitsBehind;

  const BranchSyncStatusIndicator({
    super.key,
    required this.commitsAhead,
    required this.commitsBehind,
  });

  @override
  Widget build(BuildContext context) {
    if (commitsAhead == 0 && commitsBehind == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final tooltipParts = [
      if (commitsAhead > 0) "$commitsAhead commits ahead",
      if (commitsBehind > 0) "$commitsBehind commits behind",
    ];

    return Tooltip(
      message: tooltipParts.join(" / "),
      waitDuration: const Duration(milliseconds: 450),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (commitsAhead > 0) ...[
            Icon(
              Icons.arrow_upward,
              size: 13,
              color: theme.openGit.success,
            ),
            Text(
              commitsAhead.toString(),
              style: theme.openGitCaption.copyWith(
                color: theme.openGit.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (commitsAhead > 0 && commitsBehind > 0) const SizedBox(width: 6),
          if (commitsBehind > 0) ...[
            Icon(
              Icons.arrow_downward,
              size: 13,
              color: theme.openGit.warning,
            ),
            Text(
              commitsBehind.toString(),
              style: theme.openGitCaption.copyWith(
                color: theme.openGit.warning,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
