part of 'commit_history_bloc.dart';

sealed class CommitHistoryEvent {}

class LoadCommitHistory extends CommitHistoryEvent {
  final int limit;

  LoadCommitHistory({this.limit = 100});
}
