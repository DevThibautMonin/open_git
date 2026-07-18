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

class UpdateCommitSummary extends WorkingDirectoryEvent {
  final String summary;

  UpdateCommitSummary({
    required this.summary,
  });
}

class UpdateCommitDescription extends WorkingDirectoryEvent {
  final String description;

  UpdateCommitDescription({
    required this.description,
  });
}

class ToggleAmendLatestCommit extends WorkingDirectoryEvent {
  final bool amend;

  ToggleAmendLatestCommit({
    required this.amend,
  });
}

class ClearCommitForm extends WorkingDirectoryEvent {
  ClearCommitForm();
}

class AmendCommit extends WorkingDirectoryEvent {
  final String summary;
  final String? description;

  AmendCommit({
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

class DiscardFileChanges extends WorkingDirectoryEvent {
  final GitFileEntity? file;

  DiscardFileChanges({
    this.file,
  });
}

class ToggleAllFilesStaging extends WorkingDirectoryEvent {
  final bool stage;

  ToggleAllFilesStaging({
    required this.stage,
  });
}

class ClearSelectedFile extends WorkingDirectoryEvent {
  ClearSelectedFile();
}

class LoadStashes extends WorkingDirectoryEvent {
  LoadStashes();
}

class CreateStash extends WorkingDirectoryEvent {
  final String? message;

  CreateStash({
    this.message,
  });
}

class ApplyStash extends WorkingDirectoryEvent {
  final GitStashEntity stash;

  ApplyStash({
    required this.stash,
  });
}

class PopStash extends WorkingDirectoryEvent {
  final GitStashEntity stash;

  PopStash({
    required this.stash,
  });
}

class DropStash extends WorkingDirectoryEvent {
  final GitStashEntity stash;

  DropStash({
    required this.stash,
  });
}
