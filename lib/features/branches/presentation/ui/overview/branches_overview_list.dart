import "package:flutter/material.dart";
import "package:open_git/features/branches/presentation/ui/overview/branches_overview_row.dart";
import "package:open_git/features/branches/presentation/ui/overview/branches_overview_table_header.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class BranchesOverviewList extends StatelessWidget {
  final List<BranchEntity> branches;
  final BranchEntity? selectedBranch;
  final ValueChanged<BranchEntity> onSelected;
  final ValueChanged<BranchEntity> onCheckout;
  final ValueChanged<BranchEntity> onDelete;

  const BranchesOverviewList({
    super.key,
    required this.branches,
    required this.selectedBranch,
    required this.onSelected,
    required this.onCheckout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return const DesktopEmptyState(
        icon: Icons.account_tree_outlined,
        title: "No local branches",
        message: "Create or checkout a branch to see it here.",
      );
    }

    return Column(
      children: [
        const BranchesOverviewTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];

              return BranchesOverviewRow(
                branch: branch,
                selected: selectedBranch?.name == branch.name,
                onSelected: onSelected,
                onCheckout: onCheckout,
                onDelete: onDelete,
              );
            },
          ),
        ),
      ],
    );
  }
}
