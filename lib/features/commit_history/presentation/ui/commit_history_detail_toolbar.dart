import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_icon_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class CommitHistoryDetailToolbar extends StatelessWidget {
  const CommitHistoryDetailToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      color: theme.openGit.toolbar,
      bottomBorder: true,
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          DesktopIconButton(
            icon: Icons.arrow_back,
            tooltip: "Back to commits",
            onPressed: () {
              context.read<CommitHistoryBloc>().add(CloseCommitDetails());
            },
          ),
          Gaps.w8,
          Expanded(
            child: Text(
              "Commit details",
              overflow: TextOverflow.ellipsis,
              style: theme.openGitSectionLabel,
            ),
          ),
        ],
      ),
    );
  }
}
