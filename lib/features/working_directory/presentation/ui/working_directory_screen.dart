import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_viewer.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_viewer.dart';
import 'package:open_git/features/files_differences/presentation/ui/file_differences_header.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';

class WorkingDirectoryScreen extends StatelessWidget {
  const WorkingDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, diffState) {
        final selectedFile = context.watch<WorkingDirectoryBloc>().state.selectedFile;

        return Column(
          children: [
            FileDifferencesHeader(
              filePath: selectedFile?.path,
              mode: diffState.diffModeDisplay,
            ),
            const Divider(height: 1),
            Expanded(
              child: selectedFile == null
                  ? const Center(child: Text('No changes'))
                  : diffState.diffModeDisplay == DiffModeDisplay.split
                  ? SplitDiffViewer()
                  : UnifiedDiffViewer(),
            ),
          ],
        );
      },
    );
  }
}
