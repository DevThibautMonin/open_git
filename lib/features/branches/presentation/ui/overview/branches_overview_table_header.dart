import "package:flutter/material.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class BranchesOverviewTableHeader extends StatelessWidget {
  const BranchesOverviewTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.openGit.toolbar,
        border: Border(
          bottom: BorderSide(color: theme.openGit.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text("Branch", style: theme.openGitSectionLabel),
          ),
          Expanded(
            flex: 3,
            child: Text("Main status", style: theme.openGitSectionLabel),
          ),
          Expanded(
            flex: 3,
            child: Text("Remote", style: theme.openGitSectionLabel),
          ),
          Expanded(
            flex: 5,
            child: Text("Last commit", style: theme.openGitSectionLabel),
          ),
          SizedBox(
            width: 118,
            child: Text("Updated", style: theme.openGitSectionLabel),
          ),
          const SizedBox(width: 96),
        ],
      ),
    );
  }
}
