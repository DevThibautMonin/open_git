part of 'branches_bloc.dart';

sealed class BranchesEvent {}

class SwitchToBranch extends BranchesEvent {
  final BranchEntity branch;

  SwitchToBranch({
    required this.branch,
  });
}

class GetRepositoryBranches extends BranchesEvent {
  GetRepositoryBranches();
}
