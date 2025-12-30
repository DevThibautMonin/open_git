import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_line_row.dart';

class SplitDiffHunkWidget extends StatelessWidget {
  final DiffHunkEntity hunk;

  const SplitDiffHunkWidget({
    super.key,
    required this.hunk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...hunk.lines.map(
          (line) => SplitDiffLineRow(line: line),
        ),
      ],
    );
  }
}
