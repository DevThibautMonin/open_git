extension RepositoryFetchTimeDisplayExtension on String {
  String get lastFetchLabel {
    final date = DateTime.tryParse(this);

    if (date == null) {
      return "Never fetched";
    }

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "Last fetch just now";
    }

    if (diff.inMinutes < 60) {
      return "Last fetch ${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "Last fetch ${diff.inHours} h ago";
    }

    return "Last fetch ${diff.inDays} d ago";
  }
}
