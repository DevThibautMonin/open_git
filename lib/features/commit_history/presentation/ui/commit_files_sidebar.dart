import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_file_item.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart';

class CommitFilesSidebar extends StatelessWidget {
  const CommitFilesSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        if (state.selectedCommitFiles.isEmpty) {
          return const DesktopEmptyState(
            icon: Icons.list_alt,
            title: "No files",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesktopSectionHeader(
              title: "Committed files",
              count: state.selectedCommitFiles.length.toString(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.selectedCommitFiles.length,
                itemBuilder: (_, index) {
                  final file = state.selectedCommitFiles[index];

                  return CommitHistoryFileItem(
                    filePath: file,
                    onTap: () {
                      context.read<CommitHistoryBloc>().add(
                        SelectCommitFile(filePath: file),
                      );
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
