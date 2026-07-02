import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/current_branch_section.dart';
import 'package:open_git/features/branches/presentation/ui/local_branches_section.dart';
import 'package:open_git/features/branches/presentation/ui/remote_branches_section.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';

class BranchesSidebar extends StatelessWidget {
  const BranchesSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      color: theme.openGit.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesktopPanel(
            color: theme.openGit.toolbar,
            bottomBorder: true,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DesktopButton(
                  icon: Icons.add,
                  label: "New branch",
                  tooltip: "Create branch",
                  onPressed: () {
                    context.read<BranchesBloc>().add(
                      UpdateBranchesStatus(
                        status: BranchesBlocStatus.createNewBranchAndCheckout,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<BranchesBloc, BranchesState>(
              builder: (context, state) {
                return ListView(
                  children: [
                    if (state.currentBranch.isNotEmpty)
                      CurrentBranchSection(branch: state.currentBranch.first),

                    LocalBranchesSection(
                      branchGroups: state.localBranchGroups,
                    ),

                    RemoteBranchesSection(
                      branchGroups: state.remoteBranchGroups,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
