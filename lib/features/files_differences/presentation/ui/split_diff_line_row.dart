import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_line_content.dart';

class SplitDiffLineRow extends StatelessWidget {
  final DiffLineEntity line;

  const SplitDiffLineRow({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SplitDiffLineContent(
            visible: line.type != DiffLineType.added,
            oldLineNumber: line.oldLineNumber,
            newLineNumber: null,
            content: line.type != DiffLineType.added ? line.content : '',
            diffLineType: line.type,
          ),
        ),

        Expanded(
          child: SplitDiffLineContent(
            visible: line.type != DiffLineType.removed,
            oldLineNumber: null,
            newLineNumber: line.newLineNumber,
            content: line.type != DiffLineType.removed ? line.content : '',
            diffLineType: line.type,
          ),
        ),
      ],
    );
  }
}
