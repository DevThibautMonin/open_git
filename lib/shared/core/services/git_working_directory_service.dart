import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitWorkingDirectoryService {
  final GitCommandRunner commandRunner;

  GitWorkingDirectoryService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, List<GitFileEntity>>> getWorkingDirectoryStatus() async {
    final result = await commandRunner.run(
      GitCommands.statusPorcelain,
      allowedExitCodes: const {0, 1},
    );

    if (result.isLeft) {
      return Left(result.left);
    }

    final files = _parseGitStatusPorcelain(result.right);

    return Right(files);
  }

  Future<Either<GitServiceFailure, void>> stageFile(String filePath) async {
    final result = await commandRunner.run([...GitCommands.gitAdd, filePath]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> unstageFile(String filePath) async {
    final result = await commandRunner.run([...GitCommands.gitRestoreStaged, filePath]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> discardFileChanges(GitFileEntity file) async {
    if (file.status == GitFileStatus.untracked) {
      final result = await commandRunner.run([
        ...GitCommands.cleanFile,
        file.path,
      ]);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    if (file.staged) {
      final unstageResult = await commandRunner.run([...GitCommands.gitRestoreStaged, file.path]);
      if (unstageResult.isLeft) {
        return Left(unstageResult.left);
      }
    }

    final result = await commandRunner.run([
      ...GitCommands.restoreFile,
      file.path,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> discardAllChanges() async {
    final restoreResult = await commandRunner.run(GitCommands.restoreTrackedFiles);
    if (restoreResult.isLeft) {
      return Left(restoreResult.left);
    }

    final cleanResult = await commandRunner.run(GitCommands.removeUntrackedFiles);
    return cleanResult.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> createCommit({
    required String summary,
    String? description,
  }) async {
    final args = [
      ...GitCommands.gitCommit,
      "-m",
      summary,
    ];

    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) {
      args.addAll(["-m", desc]);
    }

    final result = await commandRunner.run(args);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  List<GitFileEntity> _parseGitStatusPorcelain(String output) {
    final files = <GitFileEntity>[];

    for (final line in output.split("\n")) {
      if (line.trim().isEmpty) continue;

      final x = line[0];
      final y = line[1];
      final path = line.substring(3).trim();

      final status = _mapGitFileStatus(x, y);
      final staged = status == GitFileStatus.untracked ? false : x != " ";

      files.add(
        GitFileEntity(
          path: path.contains("->") ? path.split("->").last.trim() : path,
          status: status,
          staged: staged,
        ),
      );
    }

    return files;
  }

  GitFileStatus _mapGitFileStatus(String x, String y) {
    if (x == "?" && y == "?") return GitFileStatus.untracked;
    if (x == "A" || y == "A") return GitFileStatus.added;
    if (x == "D" || y == "D") return GitFileStatus.deleted;
    if (x == "R" || y == "R") return GitFileStatus.renamed;
    return GitFileStatus.modified;
  }
}
