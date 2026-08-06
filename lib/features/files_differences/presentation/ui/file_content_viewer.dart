import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/extensions/markdown_preview_extension.dart";
import "package:open_git/features/files_differences/presentation/ui/image_preview_viewer.dart";
import "package:open_git/features/files_differences/presentation/ui/image_source_viewer.dart";
import "package:open_git/features/files_differences/presentation/ui/markdown_preview_viewer.dart";

class FileContentViewer extends StatelessWidget {
  const FileContentViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, state) {
        final selectedFilePath =
            state.selectedFile?.path ?? state.selectedFilePath;
        final markdownSource = selectedFilePath.canPreviewAsMarkdown
            ? state.modifiedContent
            : null;

        if (state.status == FilesDifferencesStatus.loading) {
          return const Center(
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return switch (state.fileContentDisplay) {
          FileContentDisplay.preview =>
            selectedFilePath.canPreviewAsMarkdown
                ? MarkdownPreviewViewer(markdown: state.modifiedContent)
                : ImagePreviewViewer(
                    bytes: state.imagePreviewBytes,
                    filePath: selectedFilePath,
                    source: state.sourceContent,
                    previewErrorMessage: state.previewErrorMessage,
                  ),
          FileContentDisplay.source => ImageSourceViewer(
            source: state.sourceContent ?? markdownSource,
          ),
          FileContentDisplay.diff => const SizedBox.shrink(),
        };
      },
    );
  }
}
