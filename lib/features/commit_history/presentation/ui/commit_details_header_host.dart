import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_details_header.dart";

class CommitDetailsHeaderHost extends StatelessWidget {
  const CommitDetailsHeaderHost({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        final selectedCommit = state.selectedCommit;
        if (selectedCommit == null) {
          return const SizedBox.shrink();
        }

        return CommitDetailsHeader(commit: selectedCommit);
      },
    );
  }
}
