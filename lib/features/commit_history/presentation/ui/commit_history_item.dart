import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';

class CommitHistoryItem extends StatelessWidget {
  final GitCommitEntity commit;

  const CommitHistoryItem({
    super.key,
    required this.commit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.read<CommitHistoryBloc>().add(SelectCommit(commit: commit));
      },
      title: Text(
        commit.message,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '${commit.author} • ${_formatDate(commit.date)} • ${commit.sha.substring(0, 7)}',
      ),
      leading: const Icon(Icons.commit),
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
