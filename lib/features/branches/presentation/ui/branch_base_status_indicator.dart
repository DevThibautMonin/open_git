import "package:flutter/material.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class BranchBaseStatusIndicator extends StatelessWidget {
  final BranchEntity branch;

  const BranchBaseStatusIndicator({
    super.key,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    if (!branch.hasBaseBranchComparison ||
        branch.name == branch.comparisonBaseBranchName) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isMerged = !branch.hasUnmergedBaseBranchCommits;
    final label = isMerged
        ? "merged"
        : "+${branch.commitsAheadBaseBranch} vs ${branch.comparisonBaseBranchName}";
    final tooltip = isMerged
        ? "Branch is merged into ${branch.comparisonBaseBranchName}"
        : "${branch.commitsAheadBaseBranch} commits are not in ${branch.comparisonBaseBranchName}";
    final color = isMerged ? theme.openGit.textMuted : theme.openGit.accent;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.openGitCaption.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
