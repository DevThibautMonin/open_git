part of "files_differences_bloc.dart";

enum FilesDifferencesStatus {
  initial,
  loading,
  loaded,
  error,
}

@MappableClass()
class FilesDifferencesState with FilesDifferencesStateMappable {
  final FilesDifferencesStatus status;
  final String errorMessage;
  final List<DiffHunkEntity> diff;
  final String originalContent;
  final String modifiedContent;
  final GitFileEntity? selectedFile;
  final String selectedFilePath;
  final DiffModeDisplay diffModeDisplay;
  final FileContentDisplay fileContentDisplay;
  final List<int>? imagePreviewBytes;
  final String? sourceContent;
  final String previewErrorMessage;

  const FilesDifferencesState({
    this.status = FilesDifferencesStatus.initial,
    this.errorMessage = "",
    this.diff = const [],
    this.originalContent = "",
    this.modifiedContent = "",
    this.selectedFile,
    this.selectedFilePath = "",
    this.diffModeDisplay = DiffModeDisplay.split,
    this.fileContentDisplay = FileContentDisplay.diff,
    this.imagePreviewBytes,
    this.sourceContent,
    this.previewErrorMessage = "",
  });
}
