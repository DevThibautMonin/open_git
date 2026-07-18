import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/features/files_differences/domain/enums/diff_mode_display.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/ui/file_differences_header.dart";
import "package:open_git/features/files_differences/presentation/ui/monaco_diff_viewer.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class CommitHistoryScreen extends StatelessWidget {
  const CommitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, diffState) {
        return Column(
          children: [
            BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
              builder: (context, state) {
                return FileDifferencesHeader(
                  mode: diffState.diffModeDisplay,
                  contentDisplay: FileContentDisplay.diff,
                  filePath: state.selectedCommitFile,
                );
              },
            ),
            BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
              builder: (context, state) {
                return Expanded(
                  child: state.selectedCommitFile == null
                      ? DesktopEmptyState(
                          icon: state.selectedCommit == null
                              ? Icons.history
                              : Icons.file_present_outlined,
                          title: state.selectedCommit == null
                              ? "No commit selected"
                              : "No file selected",
                          message: state.selectedCommit == null
                              ? "Select a commit from the history to inspect its changed files."
                              : "Select a file from the commit to inspect its diff.",
                        )
                      : diffState.diffModeDisplay == DiffModeDisplay.split
                      ? const MonacoDiffViewer(renderSideBySide: true)
                      : const MonacoDiffViewer(renderSideBySide: false),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
