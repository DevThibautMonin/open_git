import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_details_header.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_files_sidebar.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_history_detail_toolbar.dart";

class CommitHistoryDetailPanel extends StatelessWidget {
  const CommitHistoryDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        final selectedCommit = state.selectedCommit;

        if (selectedCommit == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const CommitHistoryDetailToolbar(),
            CommitDetailsHeader(commit: selectedCommit),
            const Expanded(
              child: CommitFilesSidebar(),
            ),
          ],
        );
      },
    );
  }
}
