import 'package:flutter/material.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_item.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart';

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
      return const DesktopEmptyState(
        icon: Icons.history,
        title: "No commits yet",
      );
    }

    return ListView.builder(
      itemCount: commits.length,
      itemBuilder: (context, index) {
        final commit = commits[index];
        return CommitHistoryItem(commit: commit);
      },
    );
  }
}
