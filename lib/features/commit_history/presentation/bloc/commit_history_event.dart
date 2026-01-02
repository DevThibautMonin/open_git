part of 'commit_history_bloc.dart';

sealed class CommitHistoryEvent {}

class LoadCommitHistory extends CommitHistoryEvent {
  final int limit;

  LoadCommitHistory({this.limit = 100});
}

class SelectCommit extends CommitHistoryEvent {
  final GitCommitEntity commit;

  SelectCommit({required this.commit});
}

class SelectCommitFile extends CommitHistoryEvent {
  final String filePath;

  SelectCommitFile({required this.filePath});
}

class ClearSelectedCommitFile extends CommitHistoryEvent {
  ClearSelectedCommitFile();
}
