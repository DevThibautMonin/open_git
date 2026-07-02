import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart';

class CurrentBranchSection extends StatelessWidget {
  final BranchEntity branch;

  const CurrentBranchSection({
    super.key,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DesktopSectionHeader(title: "Current"),
        BranchItem(branch: branch),
      ],
    );
  }
}
