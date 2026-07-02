import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_layout.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_line_colors.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_line_content.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class UnifiedDiffLineItem extends StatelessWidget {
  final DiffLineEntity line;

  const UnifiedDiffLineItem({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: line.type.themedBackgroundColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: DiffLayout.gutterWidth,
            child: DiffLineContent(
              oldLineNumber: line.oldLineNumber,
              newLineNumber: line.newLineNumber,
              diffLineType: line.type,
            ),
          ),

          Gaps.w8,

          Expanded(
            child: Text(
              line.content,
              style: theme.openGitMono.copyWith(
                fontFamily: 'monospace',
                fontSize: 13,
                color: theme.openGit.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
