part of 'working_directory_bloc.dart';

sealed class WorkingDirectoryEvent {}

class GetRepositoryStatus extends WorkingDirectoryEvent {
  GetRepositoryStatus();
}

class AddCommit extends WorkingDirectoryEvent {
  final String summary;
  final String? description;

  AddCommit({
    required this.summary,
    this.description,
  });
}

class ToggleFileStaging extends WorkingDirectoryEvent {
  final GitFileEntity file;
  final bool stage;

  ToggleFileStaging({
    required this.file,
    required this.stage,
  });
}

class PushCommits extends WorkingDirectoryEvent {
  PushCommits();
}

class UpdateWorkingDirectoryStatus extends WorkingDirectoryEvent {
  final WorkingDirectoryBlocStatus status;

  UpdateWorkingDirectoryStatus({
    required this.status,
  });
}

class SelectFile extends WorkingDirectoryEvent {
  final GitFileEntity file;
  SelectFile({
    required this.file,
  });
}

class DiscardAllChanges extends WorkingDirectoryEvent {
  DiscardAllChanges();
}
