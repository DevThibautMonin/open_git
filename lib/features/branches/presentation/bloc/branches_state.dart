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

  List<BranchGroupEntity> get localBranchGroups => _groupBranches(localBranches);

  List<BranchGroupEntity> get remoteBranchGroups => _groupBranches(remoteOnlyBranches);

  /// Helper method to group branches by their prefix
  List<BranchGroupEntity> _groupBranches(List<BranchEntity> branches) {
    // Group branches by prefix
    final Map<String, List<BranchEntity>> groupedMap = {};
    final List<BranchEntity> ungrouped = [];

    for (final branch in branches) {
      final prefix = BranchGroupEntity.extractPrefix(branch.name);

      if (prefix.isEmpty) {
        ungrouped.add(branch);
      } else {
        groupedMap.putIfAbsent(prefix, () => []).add(branch);
      }
    }

    // Convert to list of BranchGroupEntity
    final List<BranchGroupEntity> result = [];

    // Add grouped branches (sorted by prefix name)
    final sortedPrefixes = groupedMap.keys.toList()..sort();
    for (final prefix in sortedPrefixes) {
      final branchesInGroup = groupedMap[prefix]!..sort((a, b) => a.name.compareTo(b.name));
      result.add(
        BranchGroupEntity(
          prefix: prefix,
          branches: branchesInGroup,
        ),
      );
    }

    // Add ungrouped branches as individual "groups" at the end
    for (final branch in ungrouped..sort((a, b) => a.name.compareTo(b.name))) {
      result.add(
        BranchGroupEntity(
          prefix: '',
          branches: [branch],
        ),
      );
    }

    return result;
  }
}
