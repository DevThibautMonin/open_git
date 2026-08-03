import "package:open_git/shared/domain/entities/branch_entity.dart";

extension BranchOverviewDisplayExtension on BranchEntity {
  String get baseStatusLabel {
    if (!hasBaseBranchComparison) {
      return "no base";
    }

    if (name == comparisonBaseBranchName) {
      return "base";
    }

    if (commitsAheadBaseBranch == 0) {
      return "merged";
    }

    return "+$commitsAheadBaseBranch vs $comparisonBaseBranchName";
  }

  String get baseStatusDescription {
    if (!hasBaseBranchComparison) {
      return "No main or master branch found";
    }

    if (name == comparisonBaseBranchName) {
      return "Comparison base branch";
    }

    if (commitsAheadBaseBranch == 0) {
      return "Safe to delete after review";
    }

    return "$commitsAheadBaseBranch commits not in $comparisonBaseBranchName";
  }

  String get remoteSyncLabel {
    if (!hasUpstream) {
      return "not published";
    }

    if (commitsAhead == 0 && commitsBehind == 0) {
      return "up to date";
    }

    if (commitsAhead > 0 && commitsBehind > 0) {
      return "$commitsAhead ahead / $commitsBehind behind";
    }

    if (commitsAhead > 0) {
      return "$commitsAhead ahead";
    }

    return "$commitsBehind behind";
  }

  String get lastCommitDateLabel {
    final date = lastCommitDate;

    if (date == null) {
      return "-";
    }

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "just now";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} h ago";
    }

    return "${diff.inDays} d ago";
  }

  String get lastCommitSummaryLabel {
    if (lastCommitMessage.isEmpty) {
      return "-";
    }

    return lastCommitMessage;
  }
}
