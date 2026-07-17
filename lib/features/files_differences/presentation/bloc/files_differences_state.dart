part of 'files_differences_bloc.dart';

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
  final GitFileEntity? selectedFile;
  final DiffModeDisplay diffModeDisplay;
  final FileContentDisplay fileContentDisplay;
  final List<int>? imagePreviewBytes;
  final String? sourceContent;
  final String previewErrorMessage;

  const FilesDifferencesState({
    this.status = FilesDifferencesStatus.initial,
    this.errorMessage = "",
    this.diff = const [],
    this.selectedFile,
    this.diffModeDisplay = DiffModeDisplay.split,
    this.fileContentDisplay = FileContentDisplay.diff,
    this.imagePreviewBytes,
    this.sourceContent,
    this.previewErrorMessage = "",
  });
}
