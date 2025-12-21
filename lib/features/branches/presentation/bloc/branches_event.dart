part of 'branches_bloc.dart';

sealed class BranchesEvent {}

class SwitchToBranch extends BranchesEvent {
  final BranchEntity branch;

  SwitchToBranch({
    required this.branch,
  });
}

class DeleteBranch extends BranchesEvent {
  final BranchEntity branch;

  DeleteBranch({
    required this.branch,
  });
}

class UpdateBranchesStatus extends BranchesEvent {
  final BranchesBlocStatus status;

  UpdateBranchesStatus({
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
