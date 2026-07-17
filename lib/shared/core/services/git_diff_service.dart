import "dart:convert";
import "dart:io";
import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";
import "package:path/path.dart" as p;

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

  Future<Either<GitServiceFailure, ({String original, String modified})>>
  getFileDiffContentPair({
    required String filePath,
    required GitFileStatus status,
    required bool staged,
  }) async {
    switch (status) {
      case GitFileStatus.untracked:
        final modified = await getWorkingTreeFileContent(filePath: filePath);
        return modified.fold(
          (failure) => Left(failure),
          (content) => Right((original: "", modified: content)),
        );

      case GitFileStatus.added:
        final modified = staged
            ? await _getIndexFileContent(filePath)
            : await getWorkingTreeFileContent(filePath: filePath);
        return modified.fold(
          (failure) => Left(failure),
          (content) => Right((original: "", modified: content)),
        );

      case GitFileStatus.deleted:
        final original = staged
            ? await _getHeadFileContent(filePath)
            : await _getIndexFileContent(filePath);
        return original.fold(
          (failure) => Left(failure),
          (content) => Right((original: content, modified: "")),
        );

      case GitFileStatus.modified:
      case GitFileStatus.renamed:
        final original = staged
            ? await _getHeadFileContent(filePath)
            : await _getIndexFileContent(filePath);
        final modified = staged
            ? await _getIndexFileContent(filePath)
            : await getWorkingTreeFileContent(filePath: filePath);

        if (original.isLeft) return Left(original.left);
        if (modified.isLeft) return Left(modified.left);

        return Right((original: original.right, modified: modified.right));
    }
  }

  Future<Either<GitServiceFailure, ({String original, String modified})>>
  getCommitFileDiffContentPair({
    required GitCommitEntity commit,
    required String filePath,
  }) async {
    final originalRevision = commit.isMergeCommit
        ? commit.parents[0]
        : "${commit.sha}^";
    final modifiedRevision = commit.isMergeCommit
        ? commit.parents[1]
        : commit.sha;

    final original = await _getRevisionFileContent(
      revision: originalRevision,
      filePath: filePath,
    );
    final modified = await _getRevisionFileContent(
      revision: modifiedRevision,
      filePath: filePath,
    );

    if (original.isLeft) return Left(original.left);
    if (modified.isLeft) return Left(modified.left);

    return Right((original: original.right, modified: modified.right));
  }

  Future<Either<GitServiceFailure, String>> getWorkingTreeFileContent({
    required String filePath,
  }) async {
    final bytes = await getWorkingTreeFileBytes(filePath: filePath);

    return bytes.fold(
      (failure) => Left(failure),
      (data) => Right(utf8.decode(data, allowMalformed: true)),
    );
  }

  Future<Either<GitServiceFailure, List<int>>> getWorkingTreeFileBytes({
    required String filePath,
  }) async {
    final repoPathResult = commandRunner.getRepoPath();

    if (repoPathResult.isLeft) {
      return Left(repoPathResult.left);
    }

    try {
      final path = p.normalize(p.join(repoPathResult.right, filePath));
      final file = File(path);

      if (!await file.exists()) {
        return Left(RepositoryPathInvalidFailure(command: path));
      }

      return Right(await file.readAsBytes());
    } catch (e) {
      return Left(
        GitServiceUnknownFailure(
          command: "read file $filePath",
          stdErr: e.toString(),
        ),
      );
    }
  }

  Future<Either<GitServiceFailure, String>> _getHeadFileContent(
    String filePath,
  ) {
    return _getRevisionFileContent(
      revision: "HEAD",
      filePath: filePath,
    );
  }

  Future<Either<GitServiceFailure, String>> _getIndexFileContent(
    String filePath,
  ) {
    return _getRevisionFileContent(
      revision: "",
      filePath: filePath,
    );
  }

  Future<Either<GitServiceFailure, String>> _getRevisionFileContent({
    required String revision,
    required String filePath,
  }) async {
    final object = revision.isEmpty ? ":$filePath" : "$revision:$filePath";
    final result = await commandRunner.run(
      ["show", object],
      allowedExitCodes: const {0, 128},
    );

    return result.fold(
      (failure) => Left(failure),
      (content) => Right(content),
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
