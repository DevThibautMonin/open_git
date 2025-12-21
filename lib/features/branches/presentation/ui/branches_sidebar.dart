import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class BranchesSidebar extends StatelessWidget {
  final List<BranchEntity> branches;
  final Function() onNewBranch;

  const BranchesSidebar({
    super.key,
    required this.branches,
    required this.onNewBranch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  'BRANCHES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onNewBranch,
                  child: Icon(
                    Icons.add_circle_outline_sharp,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          Gaps.h8,
          Expanded(
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];

                return BranchItem(
                  branch: branch,
                  onDoubleTap: () {
                    context.read<BranchesBloc>().add(SwitchToBranch(branch: branch));
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
