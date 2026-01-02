class GitCommitEntity {
  final String sha;
  final String author;
  final DateTime date;
  final String message;
  final bool isUnpushed;

  GitCommitEntity({
    required this.sha,
    required this.author,
    required this.date,
    required this.message,
    required this.isUnpushed,
  });
}
