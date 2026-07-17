import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/files_differences/domain/enums/diff_mode_display.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/ui/image_diff_viewer.dart";
import "package:open_git/features/files_differences/presentation/ui/monaco_diff_viewer.dart";
import "package:open_git/features/files_differences/presentation/ui/file_differences_header.dart";
import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class WorkingDirectoryScreen extends StatelessWidget {
  const WorkingDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, diffState) {
        final selectedFile = context
            .watch<WorkingDirectoryBloc>()
            .state
            .selectedFile;

        return Column(
          children: [
            FileDifferencesHeader(
              filePath: selectedFile?.path,
              mode: diffState.diffModeDisplay,
              contentDisplay: diffState.fileContentDisplay,
              canPreview: diffState.imagePreviewBytes != null,
              canShowSource: diffState.sourceContent != null,
            ),
            Expanded(
              child: selectedFile == null
                  ? const DesktopEmptyState(
                      icon: Icons.file_present_outlined,
                      title: "No file selected",
                      message: "Select a changed file to inspect its diff.",
                    )
                  : diffState.fileContentDisplay == FileContentDisplay.diff
                  ? diffState.diffModeDisplay == DiffModeDisplay.split
                        ? const MonacoDiffViewer(renderSideBySide: true)
                        : const MonacoDiffViewer(renderSideBySide: false)
                  : const ImageDiffViewer(),
            ),
          ],
        );
      },
    );
  }
}
