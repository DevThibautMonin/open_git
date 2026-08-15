import "package:open_git/shared/domain/enums/conventional_commit_type.dart";

extension CommitSummaryExtensions on String {
  String withConventionalCommitType(ConventionalCommitType type) {
    final trimmed = trimLeft();
    final content = trimmed.replaceFirst(
      RegExp(
        r"^(feat|fix|refactor|docs|test|chore|style|perf|ci|build)"
        r"(\([^)]+\))?!?:\s*",
      ),
      "",
    );

    if (content.isEmpty) {
      return "${type.value}: ";
    }

    return "${type.value}: $content";
  }
}
