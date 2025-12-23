part of 'home_bloc.dart';

enum HomeBlocStatus {
  initial,
  loading,
  loaded,
  error,
  repositorySelected,
  askForCloningRepository,
  cloneSuccess,
  cloning,
  cloneProgress,
}

@MappableClass()
class HomeState with HomeStateMappable {
  final HomeBlocStatus status;
  final String currentRepositoryName;
  final String repositoryPath;
  final String errorMessage;
  final String cloneDestinationPath;
  final String cloneRepositoryUrl;
  final double cloneProgress;

  const HomeState({
    this.status = HomeBlocStatus.initial,
    this.currentRepositoryName = "",
    this.repositoryPath = "",
    this.errorMessage = "",
    this.cloneDestinationPath = "",
    this.cloneRepositoryUrl = "",
    this.cloneProgress = 0.0,
  });
}
