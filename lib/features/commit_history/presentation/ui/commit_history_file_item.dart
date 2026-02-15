import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class CommitHistoryFileItem extends StatelessWidget {
  final String filePath;
  final VoidCallback onTap;

  const CommitHistoryFileItem({
    super.key,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        final isSelected = state.selectedCommitFile == filePath;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: isSelected
                  ? BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                      border: Border(
                        left: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    FileTypeIcon(type: filePath.fileType),
                    Gaps.w8,
                    Expanded(
                      child: Text(
                        filePath,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
