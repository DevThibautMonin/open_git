import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';

class CurrentBranchSection extends StatelessWidget {
  final BranchEntity branch;

  const CurrentBranchSection({
    super.key,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "Current",
            style: theme.textTheme.labelMedium,
          ),
        ),
        BranchItem(branch: branch),
      ],
    );
  }
}
