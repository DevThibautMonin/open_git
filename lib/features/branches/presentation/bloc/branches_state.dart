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
  askForRenamingBranch,
  branchRenamed,
  fetchingBranches,
}

@MappableClass()
class BranchesState with BranchesStateMappable {
  final BranchesBlocStatus status;
  final List<BranchEntity> branches;
  final String errorMessage;
  final BranchEntity? selectedBranch;
  final bool selectedBranchHasUpstream;

  const BranchesState({
    this.status = BranchesBlocStatus.initial,
    this.branches = const [],
    this.errorMessage = "",
    this.selectedBranch,
    this.selectedBranchHasUpstream = false,
  });

  List<BranchEntity> get currentBranch => branches.where((b) => b.isCurrent).toList();

  List<BranchEntity> get localBranches => branches.where((b) => !b.isRemote && !b.isCurrent).toList();

  List<BranchEntity> get remoteOnlyBranches => branches.where((b) => b.isRemote && !b.existsLocally).toList();
}
