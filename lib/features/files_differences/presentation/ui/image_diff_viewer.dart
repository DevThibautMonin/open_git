import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/ui/image_preview_viewer.dart";
import "package:open_git/features/files_differences/presentation/ui/image_source_viewer.dart";

class ImageDiffViewer extends StatelessWidget {
  const ImageDiffViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, state) {
        if (state.status == FilesDifferencesStatus.loading) {
          return const Center(
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return switch (state.fileContentDisplay) {
          FileContentDisplay.preview => ImagePreviewViewer(
            bytes: state.imagePreviewBytes,
            filePath: state.selectedFile?.path ?? "",
            source: state.sourceContent,
            previewErrorMessage: state.previewErrorMessage,
          ),
          FileContentDisplay.source => ImageSourceViewer(
            source: state.sourceContent,
          ),
          FileContentDisplay.diff => const SizedBox.shrink(),
        };
      },
    );
  }
}
