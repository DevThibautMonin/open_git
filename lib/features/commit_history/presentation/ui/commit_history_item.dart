import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';
import 'package:open_git/shared/presentation/widgets/user_avatar.dart';

class CommitHistoryItem extends StatelessWidget {
  final GitCommitEntity commit;

  const CommitHistoryItem({
    super.key,
    required this.commit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        final isSelected = state.selectedCommit?.sha == commit.sha;
        final theme = Theme.of(context);

        return DesktopListRow(
          selected: isSelected,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          onTap: () {
            context.read<CommitHistoryBloc>().add(
              SelectCommit(commit: commit),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                commit.isMergeCommit ? Icons.call_merge : Icons.commit,
                size: 16,
                color: commit.isMergeCommit
                    ? theme.openGit.accent
                    : theme.openGit.textMuted,
              ),

              Gaps.w12,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commit.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.openGitBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        UserAvatar(
                          authorName: commit.author,
                          authorEmail: commit.authorEmail,
                          size: 16.0,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${commit.author} • ${_formatDate(commit.date)} • ${commit.sha.substring(0, 7)}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.openGitCaption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (commit.isUnpushed)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: theme.openGit.accent,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'just now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }

    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}
