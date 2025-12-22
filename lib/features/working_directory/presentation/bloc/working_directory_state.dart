part of 'working_directory_bloc.dart';

enum WorkingDirectoryBlocStatus {
  initial,
  loading,
  loaded,
  error,
}

@MappableClass()
class WorkingDirectoryState with WorkingDirectoryStateMappable {
  final WorkingDirectoryBlocStatus status;
  final List<GitFileEntity> files;
  final String errorMessage;
  final int commitsToPush;

  const WorkingDirectoryState({
    this.status = WorkingDirectoryBlocStatus.initial,
    this.files = const [],
    this.errorMessage = "",
    this.commitsToPush = 0,
  });
}
