part of 'branches_bloc.dart';

enum BranchesBlocStatus {
  initial,
  loading,
  loaded,
  error,
}

@MappableClass()
class BranchesState with BranchesStateMappable {
  final BranchesBlocStatus status;
  final List<BranchEntity> branches;

  const BranchesState({
    this.status = BranchesBlocStatus.initial,
    this.branches = const [],
  });
}
