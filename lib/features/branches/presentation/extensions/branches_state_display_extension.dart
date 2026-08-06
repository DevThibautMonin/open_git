import "package:open_git/features/branches/presentation/bloc/branches_bloc.dart";

extension BranchesStateDisplayExtension on BranchesState {
  String get currentBranchName {
    final currentBranches = currentBranch;

    if (currentBranches.isEmpty) {
      return "";
    }

    return currentBranches.first.name;
  }
}
