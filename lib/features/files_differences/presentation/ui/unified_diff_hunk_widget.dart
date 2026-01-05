import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_line_item.dart';

class UnifiedDiffHunkWidget extends StatelessWidget {
  final DiffHunkEntity hunk;

  const UnifiedDiffHunkWidget({
    super.key,
    required this.hunk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...hunk.lines.map((line) {
          return UnifiedDiffLineItem(line: line);
        }),
      ],
    );
  }
}
