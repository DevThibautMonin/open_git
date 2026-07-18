import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_history_detail_panel.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_history_list.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_history_search_field.dart";

class CommitHistorySidebar extends StatelessWidget {
  const CommitHistorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        if (state.selectedCommit != null) {
          return const CommitHistoryDetailPanel();
        }

        return Column(
          children: [
            const CommitHistorySearchField(),
            Expanded(
              child: CommitHistoryList(
                commits: state.commits,
                isLoading: state.status == CommitHistoryBlocStatus.loading,
              ),
            ),
          ],
        );
      },
    );
  }
}
