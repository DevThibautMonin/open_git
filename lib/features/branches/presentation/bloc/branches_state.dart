part of 'branches_bloc.dart';

enum BranchesBlocStatus {
  initial,
  loading,
  loaded,
  error,
  createNewBranchAndCheckout,
  branchCreated,
  branchesRetrieved,
  askForDeletingBranch,
}

@MappableClass()
class BranchesState with BranchesStateMappable {
  final BranchesBlocStatus status;
  final List<BranchEntity> branches;
  final String errorMessage;
  final BranchEntity? selectedBranch;

  const BranchesState({
    this.status = BranchesBlocStatus.initial,
    this.branches = const [],
    this.errorMessage = "",
    this.selectedBranch,
  });
}
