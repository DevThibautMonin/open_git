import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class BranchesSidebar extends StatelessWidget {
  const BranchesSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ActionChip(
                  avatar: const Icon(
                    Icons.add_circle_outline_sharp,
                    size: 18,
                  ),
                  label: const Text("New"),
                  onPressed: () {
                    context.read<BranchesBloc>().add(
                      UpdateBranchesStatus(
                        status: BranchesBlocStatus.createNewBranchAndCheckout,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Gaps.h8,
          Expanded(
            child: BlocBuilder<BranchesBloc, BranchesState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.branches.length,
                  itemBuilder: (context, index) {
                    final branch = state.branches[index];

                    return BranchItem(branch: branch);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
