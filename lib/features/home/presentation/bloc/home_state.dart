part of 'home_bloc.dart';

enum HomeBlocStatus {
  initial,
  loading,
  loaded,
  error,
  repositorySelected,
}

@MappableClass()
class HomeState with HomeStateMappable {
  final HomeBlocStatus status;
  final String currentRepositoryName;
  final String repositoryPath;

  const HomeState({
    this.status = HomeBlocStatus.initial,
    this.currentRepositoryName = "",
    this.repositoryPath = "",
  });
}
