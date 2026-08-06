extension RepositoryBranchDisplayExtension on String {
  String withBranchName(String branchName) {
    if (branchName.isEmpty) {
      return this;
    }

    return "$this ($branchName)";
  }
}
