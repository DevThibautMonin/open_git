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
  final bool isDiffLoading;

  const FilesDifferencesState({
    this.status = FilesDifferencesStatus.initial,
    this.errorMessage = "",
    this.diff = const [],
    this.selectedFile,
    this.isDiffLoading = false,
  });
}
