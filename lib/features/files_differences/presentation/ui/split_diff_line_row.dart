import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';

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
          child: _SideLine(
            visible: line.type != DiffLineType.added,
            lineNumber: line.oldLineNumber,
            content: line.type == DiffLineType.removed || line.type == DiffLineType.unchanged ? line.content : '',
            background: line.type == DiffLineType.removed ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
          ),
        ),

        Expanded(
          child: _SideLine(
            visible: line.type != DiffLineType.removed,
            lineNumber: line.newLineNumber,
            content: line.type == DiffLineType.added || line.type == DiffLineType.unchanged ? line.content : '',
            background: line.type == DiffLineType.added ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _SideLine extends StatelessWidget {
  final bool visible;
  final int? lineNumber;
  final String content;
  final Color background;

  const _SideLine({
    required this.visible,
    required this.lineNumber,
    required this.content,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container(height: 22);
    }

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(lineNumber?.toString() ?? ''),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
