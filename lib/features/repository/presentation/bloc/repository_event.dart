part of 'repository_bloc.dart';

sealed class RepositoryEvent {}

class InitLastRepository extends RepositoryEvent {
  InitLastRepository();
}

class SelectRepository extends RepositoryEvent {
  SelectRepository();
}

class UpdateRepositoryStatus extends RepositoryEvent {
  final RepositoryBlocStatus status;

  UpdateRepositoryStatus({
    required this.status,
  });
}

class ChooseCloneDirectory extends RepositoryEvent {}

class CloneRepositoryConfirmed extends RepositoryEvent {
  final String sshUrl;
  final String destinationPath;

  CloneRepositoryConfirmed({
    required this.sshUrl,
    required this.destinationPath,
  });
}

class CloneRepositoryUrlChanged extends RepositoryEvent {
  final String url;

  CloneRepositoryUrlChanged(this.url);
}

class RetrieveAppVersion extends RepositoryEvent {
  RetrieveAppVersion();
}

class SetRepositoryViewMode extends RepositoryEvent {
  final RepositoryViewMode mode;

  SetRepositoryViewMode({
    required this.mode,
  });
}
