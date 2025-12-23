part of 'home_bloc.dart';

sealed class HomeEvent {}

class InitLastRepository extends HomeEvent {
  InitLastRepository();
}

class SelectRepository extends HomeEvent {
  SelectRepository();
}

class UpdateHomeStatus extends HomeEvent {
  final HomeBlocStatus status;

  UpdateHomeStatus({
    required this.status,
  });
}

class ChooseCloneDirectory extends HomeEvent {}

class CloneRepositoryConfirmed extends HomeEvent {
  final String sshUrl;
  final String destinationPath;

  CloneRepositoryConfirmed({
    required this.sshUrl,
    required this.destinationPath,
  });
}

class CloneRepositoryUrlChanged extends HomeEvent {
  final String url;

  CloneRepositoryUrlChanged(this.url);
}
