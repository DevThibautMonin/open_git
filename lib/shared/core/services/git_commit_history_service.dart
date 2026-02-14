import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitCommitHistoryService {
  final GitCommandRunner commandRunner;

  GitCommitHistoryService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, List<GitCommitEntity>>> getCommitHistory({
    int limit = 100,
  }) async {
    final unpushedResult = await getUnpushedCommitShas();
    if (unpushedResult.isLeft) {
      return Left(unpushedResult.left);
    }

    final logResult = await commandRunner.run([
      'log',
      '--pretty=format:%H|%P|%an|%ad|%s',
      '--date=iso',
      '--max-count=$limit',
    ]);

    if (logResult.isLeft) {
      return Left(logResult.left);
    }

    final unpushedShas = unpushedResult.right;
    final output = logResult.right;

    final commits = output.split('\n').where((l) => l.isNotEmpty).map(_parseCommitLine(unpushedShas)).toList();

    return Right(commits);
  }

  Future<Either<GitServiceFailure, List<String>>> getCommitFiles(GitCommitEntity commit) async {
    if (commit.isMergeCommit) {
      return await _getMergeCommitFiles(commit);
    }

    final result = await commandRunner.run([
      ...GitCommands.showCommitFiles,
      commit.sha,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.split("\n").where((line) => line.trim().isNotEmpty).toList()),
    );
  }

  Future<Either<GitServiceFailure, Set<String>>> getUnpushedCommitShas() async {
    final result = await commandRunner.run(
      GitCommands.gitUnpushedCommits,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (_) => Right(<String>{}),
      (output) => Right(
        output.split('\n').where((l) => l.isNotEmpty).toSet(),
      ),
    );
  }

  Future<Either<GitServiceFailure, List<String>>> _getMergeCommitFiles(GitCommitEntity commit) async {
    final parent1 = commit.parents[0];
    final parent2 = commit.parents[1];

    final result = await commandRunner.run([
      "diff",
      "--name-only",
      parent1,
      parent2,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.split("\n").where((l) => l.trim().isNotEmpty).toList()),
    );
  }

  GitCommitEntity Function(String) _parseCommitLine(
    Set<String> unpushedShas,
  ) {
    return (line) {
      final p = line.split('|');

      final sha = p[0];
      final parents = p[1].split(' ').where((e) => e.isNotEmpty).toList();

      return GitCommitEntity(
        sha: sha,
        parents: parents,
        author: p[2],
        date: DateTime.parse(p[3]),
        message: p.sublist(4).join('|'),
        isUnpushed: unpushedShas.contains(sha),
      );
    };
  }
}
