import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_line_item.dart';

class DiffHunkWidget extends StatelessWidget {
  final DiffHunkEntity hunk;

  const DiffHunkWidget({
    super.key,
    required this.hunk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: hunk.lines.map((line) => DiffLineItem(line: line)).toList(),
    );
  }
}
