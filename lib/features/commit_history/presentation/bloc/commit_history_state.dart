part of 'commit_history_bloc.dart';

enum CommitHistoryBlocStatus {
  initial,
  loading,
  loaded,
  error,
}

@MappableClass()
class CommitHistoryState with CommitHistoryStateMappable {
  final CommitHistoryBlocStatus status;
  final String errorMessage;
  final List<GitCommitEntity> commits;
  final GitCommitEntity? selectedCommit;
  final List<String> selectedCommitFiles;
  final String? selectedCommitFile;

  const CommitHistoryState({
    this.status = CommitHistoryBlocStatus.initial,
    this.errorMessage = "",
    this.commits = const [],
    this.selectedCommit,
    this.selectedCommitFiles = const [],
    this.selectedCommitFile,
  });
}
