class GitCommands {
  static const List<String> currentBranch = ["rev-parse", "--abbrev-ref HEAD"];
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
}
