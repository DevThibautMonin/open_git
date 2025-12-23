import 'package:flutter/material.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_item.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';

class CommitHistoryList extends StatelessWidget {
  final List<GitCommitEntity> commits;
  final bool isLoading;

  const CommitHistoryList({
    super.key,
    required this.commits,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (commits.isEmpty) {
      return const Center(
        child: Text(
          "No commits yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: commits.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final commit = commits[index];
        return CommitHistoryItem(commit: commit);
      },
    );
  }
}
