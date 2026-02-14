import "dart:convert";
import "dart:io";
import "package:either_dart/either.dart";
import "package:file_picker/file_picker.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitService {
  final GitCommandRunner commandRunner;
  final SharedPreferencesService sharedPreferencesService;

  GitService({
    required this.commandRunner,
    required this.sharedPreferencesService,
  });

  Future<Either<GitServiceFailure, bool>> repositoryExists() async {
    final path = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);

    if (path == null || path.isEmpty) {
      return Left(RepositoryDoesntExistsFailure());
    }
    final dir = Directory(path);
    return Right(await dir.exists());
  }

  Future<Either<GitServiceFailure, void>> fetch() async {
    final result = await commandRunner.run(GitCommands.gitFetchPrune);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, String?>> selectRepository() async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path == null) {
      return Left(RepositoryNotSelectedFailure());
    }

    await sharedPreferencesService.setString(SharedPreferencesKeys.repositoryPath, path);

    return Right(path);
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

  Future<Either<GitServiceFailure, List<String>>> getCommitFiles(GitCommitEntity commit) async {
    if (commit.isMergeCommit) {
      return await getMergeCommitFiles(commit);
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

  Future<void> discardFileChanges(GitFileEntity file) async {
    if (file.status == GitFileStatus.untracked) {
      await commandRunner.run([
        ...GitCommands.cleanFile,
        file.path,
      ]);
    } else {
      if (file.staged) {
        await commandRunner.run([...GitCommands.gitRestoreStaged, file.path]);
      }

      await commandRunner.run([
        ...GitCommands.restoreFile,
        file.path,
      ]);
    }
  }

  Future<void> discardAllChanges() async {
    await commandRunner.run(GitCommands.restoreTrackedFiles);
    await commandRunner.run(GitCommands.removeUntrackedFiles);
  }

  Future<Either<GitServiceFailure, List<String>>> getMergeCommitFiles(GitCommitEntity commit) async {
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

  Future<Either<GitServiceFailure, void>> cloneRepositoryWithProgress({
    required String sshUrl,
    required String targetPath,
    required void Function(double progress) onProgress,
  }) async {
    final process = await Process.start(
      'git',
      ['clone', '--progress', sshUrl, targetPath],
    );

    final stderrBuffer = StringBuffer();

    final progressRegex = GitRegex.cloneRepositoryProgress;

    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      stderrBuffer.writeln(line);

      final match = progressRegex.firstMatch(line);
      if (match != null) {
        onProgress(double.parse(match.group(1)!) / 100);
      }
    });

    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((_) {});

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final stderr = stderrBuffer.toString().trim();

      return Left(
        GitCloneFailure(
          stdErr: stderr,
          command: 'git clone $sshUrl $targetPath',
        ),
      );
    }

    return const Right(null);
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

  Future<Either<GitServiceFailure, bool>> ensureDirectoryIsEmpty(String path) async {
    final dir = Directory(path);

    if (!await dir.exists()) {
      return const Right(false);
    }

    final isEmpty = await dir.list().isEmpty;

    if (!isEmpty) {
      return Left(DirectoryNotEmptyFailure());
    }

    return const Right(true);
  }

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

  Future<Either<GitServiceFailure, List<GitFileEntity>>> getWorkingDirectoryStatus() async {
    final result = await commandRunner.run(
      GitCommands.statusPorcelain,
      allowedExitCodes: const {0, 1},
    );

    if (result.isLeft) {
      return Left(result.left);
    }

    final files = parseGitStatusPorcelain(result.right);

    return Right(files);
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

  List<GitFileEntity> parseGitStatusPorcelain(String output) {
    final files = <GitFileEntity>[];

    for (final line in output.split("\n")) {
      if (line.trim().isEmpty) continue;

      final x = line[0];
      final y = line[1];
      final path = line.substring(3).trim();

      final status = mapGitFileStatus(x, y);
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

  Future<void> createCommit({
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

    await commandRunner.run(args);
  }

  Future<void> stageFile(String filePath) async {
    await commandRunner.run([...GitCommands.gitAdd, filePath]);
  }

  Future<void> unstageFile(String filePath) async {
    await commandRunner.run([...GitCommands.gitRestoreStaged, filePath]);
  }

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

  GitFileStatus mapGitFileStatus(String x, String y) {
    if (x == "?" && y == "?") return GitFileStatus.untracked;
    if (x == "A" || y == "A") return GitFileStatus.added;
    if (x == "D" || y == "D") return GitFileStatus.deleted;
    if (x == "R" || y == "R") return GitFileStatus.renamed;
    return GitFileStatus.modified;
  }
}
