import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_layout.dart';

class DiffLineContent extends StatelessWidget {
  final int? oldLineNumber;
  final int? newLineNumber;
  final DiffLineType diffLineType;

  const DiffLineContent({
    super.key,
    this.oldLineNumber,
    this.newLineNumber,
    required this.diffLineType,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      color: diffLineType.color,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        SizedBox(
          width: DiffLayout.signWidth,
          child: Center(
            child: Text(diffLineType.value, style: textStyle),
          ),
        ),

        SizedBox(
          width: DiffLayout.lineNumberWidth,
          child: Text(
            oldLineNumber?.toString() ?? '',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),

        SizedBox(
          width: DiffLayout.lineNumberWidth,
          child: Text(
            newLineNumber?.toString() ?? '',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
