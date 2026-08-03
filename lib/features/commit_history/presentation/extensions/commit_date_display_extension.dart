extension CommitDateDisplayExtension on DateTime {
  String get commitRelativeLabel {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) {
      return "just now";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min${diff.inMinutes > 1 ? "s" : ""} ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago";
    }

    return "${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago";
  }
}
