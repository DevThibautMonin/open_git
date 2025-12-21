class GitCommands {
  static const List<String> currentBranch = ["rev-parse", "--abbrev-ref HEAD"];
  static const List<String> listBranches = [
    "branch",
    "--format=%(refname:short)|%(HEAD)",
  ];
  static const List<String> switchToBranch = ["switch"];
}
