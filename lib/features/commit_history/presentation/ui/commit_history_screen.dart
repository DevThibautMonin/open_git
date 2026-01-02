import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/files_differences/presentation/ui/file_differences_header.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_viewer.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_viewer.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_files_sidebar.dart';

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
              child: CommitFilesSidebar(),
            ),

            const VerticalDivider(width: 1),

            Expanded(
              child: Column(
                children: [
                  BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
                    builder: (context, state) {
                      return FileDifferencesHeader(
                        mode: diffState.diffModeDisplay,
                        filePath: state.selectedCommitFile,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: diffState.diffModeDisplay == DiffModeDisplay.split ? SplitDiffViewer() : UnifiedDiffViewer(),
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
