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
  loadingStashes,
  stashCreated,
  stashApplied,
  stashPopped,
  stashDropped,
  askForDiscardAllChanges,
  askForDiscardFileChanges,
  addingCommits,
  amendingCommit,
  commitsAdded,
  commitAmended,
  noRepositorySelected,
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
  final List<GitStashEntity> stashes;
  final String commitSummary;
  final String commitDescription;
  final bool amendLatestCommit;

  const WorkingDirectoryState({
    this.status = WorkingDirectoryBlocStatus.initial,
    this.files = const [],
    this.errorMessage = "",
    this.commitsToPush = 0,
    this.gitRemoteCommand = "",
    this.hasUpstream = false,
    this.selectedFile,
    this.stashes = const [],
    this.commitSummary = "",
    this.commitDescription = "",
    this.amendLatestCommit = false,
  });
}
