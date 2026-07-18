part of "repository_bloc.dart";

enum RepositoryBlocStatus {
  initial,
  loading,
  loaded,
  error,
  repositorySelected,
  askForCloningRepository,
  cloneSuccess,
  cloning,
  cloneProgress,
  fetching,
  fetched,
  initializing,
  repositoryInitialized,
  pulling,
  pulled,
  repositoryDeleted,
}

@MappableClass()
class RepositoryState with RepositoryStateMappable {
  final RepositoryBlocStatus status;
  final String currentRepositoryName;
  final String repositoryPath;
  final String errorMessage;
  final String cloneDestinationPath;
  final String cloneRepositoryUrl;
  final double cloneProgress;
  final String version;
  final RepositoryViewMode? repositoryViewMode;
  final List<String> recentRepositoryPaths;

  const RepositoryState({
    this.status = RepositoryBlocStatus.initial,
    this.currentRepositoryName = "",
    this.repositoryPath = "",
    this.errorMessage = "",
    this.cloneDestinationPath = "",
    this.cloneRepositoryUrl = "",
    this.cloneProgress = 0.0,
    this.version = "",
    this.repositoryViewMode,
    this.recentRepositoryPaths = const [],
  });
}
