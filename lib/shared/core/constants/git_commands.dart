class GitCommands {
  static const List<String> listBranches = [
    "branch",
    "--format=%(refname:short)|%(HEAD)",
  ];
  static const List<String> switchToBranch = ["switch"];
  static const List<String> checkoutBranch = ["checkout", "-b"];
  static const List<String> deleteBranch = ["branch", "-D"];
  static const List<String> statusPorcelain = ["status", "--porcelain", "--untracked-files=all"];
  static const List<String> gitAdd = ["add"];
  static const List<String> gitCommit = ["commit"];
  static const List<String> gitRestoreStaged = ["restore", "--staged"];
  static const List<String> commitsAheadCount = ["rev-list", "--count", "@{u}..HEAD"];
  static const List<String> gitPush = ["push"];
  static const List<String> remoteVerbose = ["remote", "-v"];
  static const List<String> remoteGetOrigin = ["remote", "get-url", "origin"];
  static const List<String> getUpstreamState = ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"];
  static const List<String> publishBranch = ["push", "-u", "origin", "HEAD"];
}
