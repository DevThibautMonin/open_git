class GitCommitEntity {
  final String sha;
  final String author;
  final DateTime date;
  final String message;

  GitCommitEntity({
    required this.sha,
    required this.author,
    required this.date,
    required this.message,
  });
}
