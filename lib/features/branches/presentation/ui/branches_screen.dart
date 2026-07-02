import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/graph/branch_graph_screen.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchesBloc, BranchesState>(
      builder: (context, state) {
        if (state.status == BranchesBlocStatus.loading ||
            state.status == BranchesBlocStatus.fetchingBranches) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.graphCommits.isEmpty) {
          return const DesktopEmptyState(
            icon: Icons.account_tree_outlined,
            title: "No branch graph",
            message:
                "No branch history graph is available for this repository.",
          );
        }

        final theme = Theme.of(context);

        return DesktopPanel(
          color: theme.openGit.panel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesktopPanel(
                color: theme.openGit.toolbar,
                bottomBorder: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 16,
                      color: theme.openGit.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${state.graphCommits.length} commits",
                      style: theme.openGitTitle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: BranchGraphScreen(
                    commits: state.graphCommits,
                    rowHeight: 32,
                    laneWidth: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
