import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/features/files_differences/domain/enums/diff_mode_display.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/ui/file_differences_header.dart";
import "package:open_git/features/files_differences/presentation/ui/monaco_diff_viewer.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_files_sidebar.dart";
import "package:open_git/features/commit_history/presentation/ui/commit_details_header_host.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";

class CommitHistoryScreen extends StatelessWidget {
  const CommitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, diffState) {
        return Row(
          children: [
            const SizedBox(
              width: 300,
              child: DesktopPanel(
                rightBorder: true,
                child: Column(
                  children: [
                    CommitDetailsHeaderHost(),
                    Expanded(
                      child: CommitFilesSidebar(),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Column(
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
                            ? const DesktopEmptyState(
                                icon: Icons.file_present_outlined,
                                title: "No file selected",
                                message:
                                    "Select a file from the commit to inspect its diff.",
                              )
                            : diffState.diffModeDisplay == DiffModeDisplay.split
                            ? const MonacoDiffViewer(renderSideBySide: true)
                            : const MonacoDiffViewer(renderSideBySide: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
