import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_layout.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_line_content.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class SplitDiffLineContent extends StatelessWidget {
  final bool visible;
  final int? oldLineNumber;
  final int? newLineNumber;
  final String content;
  final DiffLineType diffLineType;

  const SplitDiffLineContent({
    super.key,
    required this.visible,
    this.oldLineNumber,
    this.newLineNumber,
    required this.content,
    required this.diffLineType,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(height: 22);
    }

    return Container(
      color: diffLineType.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: DiffLayout.gutterWidth,
            child: DiffLineContent(
              oldLineNumber: oldLineNumber,
              newLineNumber: newLineNumber,
              diffLineType: diffLineType,
            ),
          ),

          Gaps.w8,

          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
