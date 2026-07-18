import "dart:io";
import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/logger/log_service.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitCommandRunner {
  final LogService logService;
  final SharedPreferencesService sharedPreferencesService;

  GitCommandRunner({
    required this.logService,
    required this.sharedPreferencesService,
  });

  Either<GitServiceFailure, String> getRepoPath() {
    final path = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);
    if (path == null || path.isEmpty) {
      return Left(RepositoryDoesntExistsFailure());
    }
    return Right(path);
  }

  Future<Either<GitServiceFailure, String>> run(
    List<String> args, {
    Set<int> allowedExitCodes = const {0},
  }) async {
    final repoPathResult = getRepoPath();

    if (repoPathResult.isLeft) {
      return Left(repoPathResult.left);
    }

    return runInDirectory(
      args,
      workingDirectory: repoPathResult.right,
      allowedExitCodes: allowedExitCodes,
    );
  }

  Future<Either<GitServiceFailure, String>> runInDirectory(
    List<String> args, {
    required String workingDirectory,
    Set<int> allowedExitCodes = const {0},
  }) async {
    try {
      final dir = Directory(workingDirectory);
      if (!await dir.exists()) {
        return Left(
          RepositoryPathInvalidFailure(
            command: 'git ${args.join(" ")}',
          ),
        );
      }

      logService.debug("Git command : git $args");

      final result = await Process.run(
        "git",
        args,
        workingDirectory: workingDirectory,
      );

      if (!allowedExitCodes.contains(result.exitCode)) {
        logService.error(result.stderr.toString());

        return Left(
          mapGitFailure(result.stderr.toString(), args),
        );
      }

      return Right(result.stdout.toString());
    } on ProcessException catch (e) {
      logService.error(e.toString());

      if (e.executable == 'git') {
        return Left(GitNotFoundFailure());
      }

      return Left(
        GitProcessFailure(
          command: 'git ${args.join(" ")}',
          stdErr: e.message,
        ),
      );
    } catch (e) {
      logService.error(e.toString());

      return Left(
        GitProcessFailure(
          command: 'git ${args.join(" ")}',
          stdErr: e.toString(),
        ),
      );
    }
  }

  GitServiceFailure mapGitFailure(String stderr, List<String> args) {
    final error = stderr.toLowerCase();

    if (error.contains("host key verification failed")) {
      return GitSshHostVerificationFailure();
    }
    if (error.contains("permission denied (publickey)")) {
      return GitSshPermissionDeniedFailure();
    }
    if (error.contains("could not read username")) {
      return GitHttpsAuthRequiredFailure();
    }
    if (error.contains("not possible to fast-forward") ||
        error.contains("divergent branches") ||
        error.contains("need to specify how to reconcile divergent branches")) {
      return GitPullNotFastForwardFailure(
        command: "git ${args.join(" ")}",
        stdErr: stderr,
      );
    }


    return GitServiceUnknownFailure(
      command: "git ${args.join(" ")}",
      stdErr: stderr,
    );
  }
}
