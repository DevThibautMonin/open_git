import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class LocalBranchesSection extends StatelessWidget {
  final List<BranchEntity> branches;

  const LocalBranchesSection({
    super.key,
    required this.branches,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (branches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.h8,
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "Local branches",
            style: theme.textTheme.labelMedium,
          ),
        ),
        ...branches.map((b) {
          return BranchItem(branch: b);
        }),
      ],
    );
  }
}
