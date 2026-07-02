import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class CommitDetailsHeader extends StatelessWidget {
  final GitCommitEntity commit;

  const CommitDetailsHeader({
    super.key,
    required this.commit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      color: theme.openGit.toolbar,
      bottomBorder: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            commit.isMergeCommit ? Icons.call_merge : Icons.commit,
            size: 18,
            color: commit.isMergeCommit
                ? theme.openGit.accent
                : theme.openGit.textMuted,
          ),
          Gaps.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        commit.message,
                        style: theme.openGitTitle.copyWith(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (commit.isUnpushed) ...[
                      Gaps.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.openGit.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: theme.openGit.accent.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 10,
                              color: theme.openGit.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Unpushed',
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.openGit.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${commit.author} • ${commit.sha.substring(0, 7)} • ${_formatDate(commit.date)}',
                  style: theme.openGitCaption,
                ),
                if (commit.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: SingleChildScrollView(
                      child: Text(
                        commit.description,
                        style: theme.openGitCaption.copyWith(
                          color: theme.openGit.textSecondary,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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

    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}
