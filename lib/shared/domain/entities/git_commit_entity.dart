class GitCommitEntity {
  final String sha;
  final List<String> parents;
  final String author;
  final DateTime date;
  final String message;
  final String description;
  final bool isUnpushed;

  bool get isMergeCommit => parents.length > 1;

  GitCommitEntity({
    required this.sha,
    required this.parents,
    required this.author,
    required this.date,
    required this.message,
    this.description = '',
    required this.isUnpushed,
  });
}
