import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_file_item.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class CommitFilesSidebar extends StatelessWidget {
  const CommitFilesSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        if (state.selectedCommitFiles.isEmpty) {
          return const Center(
            child: Text(
              "No files",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.list),
                  Gaps.w4,
                  Text("${state.selectedCommitFiles.length} committed file${state.selectedCommitFiles.length > 1 ? "s" : ""}"),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.selectedCommitFiles.length,
                itemBuilder: (_, index) {
                  final file = state.selectedCommitFiles[index];

                  return CommitHistoryFileItem(
                    filePath: file,
                    onTap: () {
                      context.read<CommitHistoryBloc>().add(SelectCommitFile(filePath: file));
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
