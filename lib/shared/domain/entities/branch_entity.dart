import 'package:dart_mappable/dart_mappable.dart';

part 'branch_entity.mapper.dart';

@MappableClass()
class BranchEntity with BranchEntityMappable {
  final String name;
  final bool isCurrent;
  final bool isRemote;
  final bool existsLocally;
  final bool hasUpstream;
  final bool deletedOnRemote;
  final int commitsAhead;
  final int commitsBehind;
  final String comparisonBaseBranchName;
  final int commitsAheadBaseBranch;
  final int commitsBehindBaseBranch;
  final String lastCommitSha;
  final String lastCommitAuthor;
  final DateTime? lastCommitDate;
  final String lastCommitMessage;

  const BranchEntity({
    required this.isCurrent,
    required this.name,
    required this.isRemote,
    required this.existsLocally,
    this.hasUpstream = false,
    this.deletedOnRemote = false,
    this.commitsAhead = 0,
    this.commitsBehind = 0,
    this.comparisonBaseBranchName = "",
    this.commitsAheadBaseBranch = 0,
    this.commitsBehindBaseBranch = 0,
    this.lastCommitSha = "",
    this.lastCommitAuthor = "",
    this.lastCommitDate,
    this.lastCommitMessage = "",
  });

  bool get hasBaseBranchComparison => comparisonBaseBranchName.isNotEmpty;

  bool get hasUnmergedBaseBranchCommits => commitsAheadBaseBranch > 0;
}
