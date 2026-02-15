import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branch_group_header.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_group_entity.dart';

class BranchGroup extends StatelessWidget {
  final BranchGroupEntity group;
  final bool isExpanded;
  final VoidCallback onToggle;

  const BranchGroup({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // If ungrouped (single branch without prefix), render directly
    if (group.prefix.isEmpty && group.branches.length == 1) {
      return BranchItem(branch: group.branches.first);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BranchGroupHeader(
          prefix: group.prefix,
          branchCount: group.count,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  children: group.branches.map((branch) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16), // Indent grouped items
                      child: BranchItem(branch: branch),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
