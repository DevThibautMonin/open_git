class GitRegex {
  static final httpsMatch = RegExp(r"https://[^/:]+[:/]+([^/]+/[^/]+?)(\.git)?$");
  static final sshMatch = RegExp(r"git@[^:]+:([^/]+/[^/]+?)(\.git)?$");
  static final cloneRepositoryProgress = RegExp(r"Receiving objects:\s+(\d+)%");
  static final diff = RegExp(r'@@ -(\d+),?\d* \+(\d+),?\d* @@');
  static final line = RegExp(r"\s+");
}
