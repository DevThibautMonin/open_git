import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            commit.isMergeCommit ? Icons.call_merge : Icons.commit,
            size: 18,
            color: commit.isMergeCommit ? theme.colorScheme.secondary : theme.colorScheme.primary,
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (commit.isUnpushed) ...[
                      Gaps.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 10,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Unpushed',
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.colorScheme.primary,
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                if (commit.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: SingleChildScrollView(
                      child: Text(
                        commit.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
