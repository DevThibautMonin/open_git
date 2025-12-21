part of 'branches_bloc.dart';

sealed class BranchesEvent {}

class SwitchToBranch extends BranchesEvent {
  final BranchEntity branch;

  SwitchToBranch({
    required this.branch,
  });
}

class UpdateStatus extends BranchesEvent {
  final BranchesBlocStatus status;

  UpdateStatus({
    required this.status,
  });
}

class GetRepositoryBranches extends BranchesEvent {
  GetRepositoryBranches();
}

class CreateNewBranchAndCheckout extends BranchesEvent {
  final String branchName;

  CreateNewBranchAndCheckout({
    required this.branchName,
  });
}
