import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitDiffService {
  final GitCommandRunner commandRunner;

  GitDiffService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, String>> getFileDiff({
    required String filePath,
    required GitFileStatus status,
    required bool staged,
  }) async {
    final args = _buildDiffArgs(
      filePath: filePath,
      status: status,
      staged: staged,
    );

    final result = await commandRunner.run(
      args,
      allowedExitCodes: const {0, 1},
    );

    if (result.isLeft) {
      return Left(result.left);
    }

    return Right(result.right);
  }

  Future<Either<GitServiceFailure, String>> getCommitFileDiff({
    required GitCommitEntity commit,
    required String filePath,
  }) async {
    late final List<String> args;

    if (commit.isMergeCommit) {
      args = [
        "diff",
        commit.parents[0],
        commit.parents[1],
        "--",
        filePath,
      ];
    } else {
      args = [
        "diff",
        "${commit.sha}^",
        commit.sha,
        "--",
        filePath,
      ];
    }

    final result = await commandRunner.run(
      args,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  List<String> _buildDiffArgs({
    required String filePath,
    required GitFileStatus status,
    required bool staged,
  }) {
    switch (status) {
      case GitFileStatus.untracked:
        return [
          'diff',
          '--no-index',
          '/dev/null',
          filePath,
        ];

      case GitFileStatus.added:
        return [
          'diff',
          '--cached',
          '--unified=3',
          '--',
          filePath,
        ];

      case GitFileStatus.deleted:
        return [
          'diff',
          'HEAD',
          '--unified=3',
          '--',
          filePath,
        ];

      case GitFileStatus.modified:
      case GitFileStatus.renamed:
        return [
          'diff',
          if (staged) '--cached',
          '--unified=3',
          '--',
          filePath,
        ];
    }
  }
}
