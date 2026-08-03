import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/branches/presentation/bloc/branches_bloc.dart";
import "package:open_git/features/branches/presentation/ui/overview/branch_detail_panel.dart";
import "package:open_git/features/branches/presentation/ui/overview/branches_overview_header.dart";
import "package:open_git/features/branches/presentation/ui/overview/branches_overview_list.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";

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

        final theme = Theme.of(context);
        final localBranches =
            state.branches.where((branch) {
              return !branch.isRemote;
            }).toList()..sort((a, b) {
              if (a.isCurrent && !b.isCurrent) return -1;
              if (!a.isCurrent && b.isCurrent) return 1;
              return a.name.compareTo(b.name);
            });
        final currentBranch = state.currentBranch.isNotEmpty
            ? state.currentBranch.first
            : null;
        final firstBranch = localBranches.isNotEmpty
            ? localBranches.first
            : null;
        BranchEntity? matchingSelectedBranch;

        for (final branch in localBranches) {
          if (branch.name == state.selectedBranch?.name) {
            matchingSelectedBranch = branch;
            break;
          }
        }

        final selectedBranch =
            matchingSelectedBranch ?? currentBranch ?? firstBranch;
        final unmergedCount = localBranches.where((branch) {
          return branch.hasUnmergedBaseBranchCommits;
        }).length;
        final remoteWorkCount = localBranches.where((branch) {
          return branch.commitsAhead > 0 || branch.commitsBehind > 0;
        }).length;

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
                child: BranchesOverviewHeader(
                  branchCount: localBranches.length,
                  unmergedCount: unmergedCount,
                  remoteWorkCount: remoteWorkCount,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: BranchesOverviewList(
                        branches: localBranches,
                        selectedBranch: selectedBranch,
                        onSelected: (branch) {
                          context.read<BranchesBloc>().add(
                            UpdateSelectedBranch(branch: branch),
                          );
                        },
                        onCheckout: (branch) {
                          context.read<BranchesBloc>().add(
                            SwitchToBranch(branch: branch),
                          );
                        },
                        onDelete: (branch) {
                          context.read<BranchesBloc>()
                            ..add(UpdateSelectedBranch(branch: branch))
                            ..add(
                              UpdateBranchesStatus(
                                status: BranchesBlocStatus.askForDeletingBranch,
                              ),
                            );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: BranchDetailPanel(
                        branch: selectedBranch,
                        onCheckout: (branch) {
                          context.read<BranchesBloc>().add(
                            SwitchToBranch(branch: branch),
                          );
                        },
                        onDelete: (branch) {
                          context.read<BranchesBloc>()
                            ..add(UpdateSelectedBranch(branch: branch))
                            ..add(
                              UpdateBranchesStatus(
                                status: BranchesBlocStatus.askForDeletingBranch,
                              ),
                            );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
