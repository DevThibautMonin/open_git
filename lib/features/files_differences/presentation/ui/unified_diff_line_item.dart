import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';

class UnifiedDiffLineItem extends StatelessWidget {
  final DiffLineEntity line;

  const UnifiedDiffLineItem({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (line.type) {
      case DiffLineType.added:
        bg = Colors.green.withValues(alpha: 0.1);
        break;
      case DiffLineType.removed:
        bg = Colors.red.withValues(alpha: 0.1);
        break;
      default:
        bg = Colors.transparent;
    }

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(line.oldLineNumber?.toString() ?? ''),
          ),
          SizedBox(
            width: 40,
            child: Text(line.newLineNumber?.toString() ?? ''),
          ),
          Expanded(
            child: Text(
              line.content,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
