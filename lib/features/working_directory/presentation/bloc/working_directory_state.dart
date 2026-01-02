part of 'working_directory_bloc.dart';

enum WorkingDirectoryBlocStatus {
  initial,
  loading,
  loaded,
  error,
  gitSshHostVerificationFailed,
  gitSshPermissionDenied,
  gitRemoteIsHttps,
  commitsPushed,
  pushingCommits,
  askForDiscardAllChanges,
  askForDiscardFileChanges,
  addingCommits,
  commitsAdded,
}

@MappableClass()
class WorkingDirectoryState with WorkingDirectoryStateMappable {
  final WorkingDirectoryBlocStatus status;
  final List<GitFileEntity> files;
  final String errorMessage;
  final int commitsToPush;
  final String gitRemoteCommand;
  final bool hasUpstream;
  final GitFileEntity? selectedFile;

  const WorkingDirectoryState({
    this.status = WorkingDirectoryBlocStatus.initial,
    this.files = const [],
    this.errorMessage = "",
    this.commitsToPush = 0,
    this.gitRemoteCommand = "",
    this.hasUpstream = false,
    this.selectedFile,
  });
}
