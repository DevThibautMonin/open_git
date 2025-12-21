part of 'branches_bloc.dart';

enum BranchesBlocStatus {
  initial,
  loading,
  loaded,
  error,
  createNewBranchAndCheckout,
  branchCreated,
}

@MappableClass()
class BranchesState with BranchesStateMappable {
  final BranchesBlocStatus status;
  final List<BranchEntity> branches;
  final String errorMessage;

  const BranchesState({
    this.status = BranchesBlocStatus.initial,
    this.branches = const [],
    this.errorMessage = "",
  });
}
