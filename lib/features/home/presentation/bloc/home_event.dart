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
