import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitRemoteService {
  final GitCommandRunner commandRunner;

  GitRemoteService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, void>> fetch() async {
    final result = await commandRunner.run(GitCommands.gitFetchPrune);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, bool>> hasUpstream() async {
    final result = await commandRunner.run(
      GitCommands.getUpstreamState,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (_) => const Right(false),
      (_) => const Right(true),
    );
  }

  Future<Either<GitServiceFailure, int>> getCommitsAheadCount() async {
    final result = await commandRunner.run(GitCommands.commitsAheadCount);

    if (result.isLeft) {
      return Left(result.left);
    }

    final count = int.tryParse(result.right.trim()) ?? 0;
    return Right(count);
  }

  Future<Either<GitServiceFailure, String>> push() async {
    final result = await commandRunner.run(GitCommands.gitPush);

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  Future<Either<GitServiceFailure, String>> pushOrPublish() async {
    final upstreamResult = await hasUpstream();

    if (upstreamResult.isLeft) {
      return Left(upstreamResult.left);
    }

    final hasUpstreamBranch = upstreamResult.right;

    if (hasUpstreamBranch) {
      return push();
    }

    return commandRunner.run(GitCommands.publishBranch);
  }

  Future<Either<GitServiceFailure, bool>> isRemoteHttps() async {
    final urlResult = await commandRunner.run(GitCommands.remoteGetOrigin);

    return urlResult.fold(
      (failure) => Left(failure),
      (data) => Right(data.startsWith("https://")),
    );
  }

  Future<Either<GitServiceFailure, String?>> getRepositorySlug() async {
    final result = await commandRunner.run(GitCommands.remoteVerbose);

    if (result.isLeft) {
      return Left(result.left);
    }

    final slug = _extractRepositorySlug(result.right);
    return Right(slug);
  }

  String? _extractRepositorySlug(String output) {
    for (final line in output.split('\n')) {
      if (!line.contains('(fetch)')) continue;

      final parts = line.split(GitRegex.line);
      if (parts.length < 2) continue;

      final url = parts[1];

      final https = GitRegex.httpsMatch.firstMatch(url);
      if (https != null) {
        return https.group(1);
      }

      final ssh = GitRegex.sshMatch.firstMatch(url);
      if (ssh != null) {
        return ssh.group(1);
      }
    }
    return null;
  }
}
