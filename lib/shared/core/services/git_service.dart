import "dart:convert";
import "dart:io";
import "package:either_dart/either.dart";
import "package:file_picker/file_picker.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/logger/log_service.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitService {
  final LogService logService;
  final SharedPreferencesService sharedPreferencesService;

  GitService({
    required this.logService,
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

  /// Récupère le chemin du repository actuellement stocké.
  Either<GitServiceFailure, String> _getRepoPath() {
    final path = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);
    if (path == null || path.isEmpty) {
      return Left(RepositoryDoesntExistsFailure());
    }
    return Right(path);
  }

  Future<Either<GitServiceFailure, Set<String>>> getRemoteBranchNames() async {
    final result = await _runGit(GitCommands.gitRemoteBranches);

    return result.map(
      (output) {
        return output.split('\n').map((l) => l.replaceFirst('origin/', '').trim()).where((l) => l.isNotEmpty).toSet();
      },
    );
  }

  Future<Either<GitServiceFailure, void>> fetch() async {
    final result = await _runGit(GitCommands.gitFetchPrune);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data);
      },
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

  Future<void> checkoutRemoteBranch(String branchName) async {
    await _runGit([
      ...GitCommands.checkoutRemoteBranch,
      'origin/$branchName',
    ]);
  }

  Future<Either<GitServiceFailure, Set<String>>> getUnpushedCommitShas() async {
    final result = await _runGit(
      GitCommands.gitUnpushedCommits,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (_) {
        return Right(<String>{});
      },
      (output) {
        return Right(
          output.split('\n').where((l) => l.isNotEmpty).toSet(),
        );
      },
    );
  }

  Future<Either<GitServiceFailure, bool>> branchHasUpstream(String branchName) async {
    final result = await _runGit(
      [...GitCommands.getBranchUpstream, "$branchName@{u}"],
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  Future<void> renameBranch({
    required String oldName,
    required String newName,
  }) async {
    await _runGit([
      ...GitCommands.renameBranch,
      oldName,
      newName,
    ]);
  }

  Future<Either<GitServiceFailure, String>> _runGit(
    List<String> args, {
    Set<int> allowedExitCodes = const {0},
  }) async {
    final repoPathResult = _getRepoPath();

    if (repoPathResult.isLeft) {
      return Left(repoPathResult.left);
    }

    final repoPath = repoPathResult.right;

    try {
      final dir = Directory(repoPath);
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
        workingDirectory: repoPath,
      );

      if (!allowedExitCodes.contains(result.exitCode)) {
        logService.error(result.stderr.toString());

        return Left(
          _mapGitFailure(result.stderr.toString(), args),
        );
      }

      return Right(result.stdout.toString());
    } on ProcessException catch (e) {
      logService.error(e.toString());

      // Git non trouvé
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

  Future<Either<GitServiceFailure, List<String>>> getCommitFiles(GitCommitEntity commit) async {
    // Merge commit
    if (commit.isMergeCommit) {
      return await getMergeCommitFiles(commit);
    }

    // Single commit
    final result = await _runGit([
      ...GitCommands.showCommitFiles,
      commit.sha,
    ]);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data.split("\n").where((line) => line.trim().isNotEmpty).toList());
      },
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

    final result = await _runGit(
      args,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data);
      },
    );
  }

  Future<void> discardFileChanges(GitFileEntity file) async {
    if (file.status == GitFileStatus.untracked) {
      await _runGit([
        ...GitCommands.cleanFile,
        file.path,
      ]);
    } else {
      // Si le fichier est staged, on le unstaged d'abord
      if (file.staged) {
        await _runGit([...GitCommands.gitRestoreStaged, file.path]);
      }

      await _runGit([
        ...GitCommands.restoreFile,
        file.path,
      ]);
    }
  }

  Future<void> discardAllChanges() async {
    await _runGit(GitCommands.restoreTrackedFiles);
    await _runGit(GitCommands.removeUntrackedFiles);
  }

  GitServiceFailure _mapGitFailure(String stderr, List<String> args) {
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

    return GitServiceUnknownFailure(
      command: "git ${args.join(" ")}",
      stdErr: stderr,
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
    final result = await _runGit(
      GitCommands.getUpstreamState,
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (_) {
        return const Right(false);
      },
      (_) {
        return const Right(true);
      },
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

    return _runGit(GitCommands.publishBranch);
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

  Future<Either<GitServiceFailure, List<BranchEntity>>> getBranches() async {
    final currentBranchResult = await _runGit(GitCommands.gitCurrentBranch);

    if (currentBranchResult.isLeft) {
      return Left(currentBranchResult.left);
    }

    final localResult = await _runGit(GitCommands.gitBranch);

    if (localResult.isLeft) {
      return Left(localResult.left);
    }

    final remoteResult = await _runGit(GitCommands.gitRemoteBranches);

    if (remoteResult.isLeft) {
      return Left(remoteResult.left);
    }

    final currentBranch = currentBranchResult.right.trim();
    final localStdout = localResult.right;
    final remoteStdout = remoteResult.right;

    final localNames = localStdout.split('\n').map((e) => e.replaceAll('*', '').trim()).where((e) => e.isNotEmpty).toSet();

    final remoteNames = remoteStdout
        .split('\n')
        .where((l) => l.isNotEmpty && !l.contains('->'))
        .map((l) => l.replaceFirst('origin/', '').trim())
        .toSet();

    final localBranches = localNames.map((name) {
      final isCurrent = name == currentBranch;
      final deletedOnRemote = !isCurrent && !remoteNames.contains(name);

      return BranchEntity(
        name: name,
        isCurrent: isCurrent,
        isRemote: false,
        existsLocally: true,
        deletedOnRemote: deletedOnRemote,
      );
    });

    final remoteBranches = remoteNames.map((name) {
      return BranchEntity(
        name: name,
        isCurrent: false,
        isRemote: true,
        existsLocally: localNames.contains(name),
        deletedOnRemote: false,
      );
    });

    return Right([
      ...localBranches,
      ...remoteBranches,
    ]);
  }

  Future<void> switchBranch(String name) async {
    await _runGit([...GitCommands.switchToBranch, name]);
  }

  Future<void> createBranchAndCheckout(String name) async {
    await _runGit([...GitCommands.checkoutBranch, name]);
  }

  Future<void> deleteBranch(String name) async {
    await _runGit([...GitCommands.deleteBranch, name]);
  }

  Future<Either<GitServiceFailure, List<String>>> getMergeCommitFiles(GitCommitEntity commit) async {
    final parent1 = commit.parents[0];
    final parent2 = commit.parents[1];

    final result = await _runGit([
      "diff",
      "--name-only",
      parent1,
      parent2,
    ]);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data.split("\n").where((l) => l.trim().isNotEmpty).toList());
      },
    );
  }

  Future<Either<GitServiceFailure, List<GitCommitEntity>>> getCommitHistory({
    int limit = 100,
  }) async {
    final unpushedResult = await getUnpushedCommitShas();
    if (unpushedResult.isLeft) {
      return Left(unpushedResult.left);
    }

    final logResult = await _runGit([
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
        message: p[4],
        isUnpushed: unpushedShas.contains(sha),
      );
    };
  }

  Future<Either<GitServiceFailure, List<GitFileEntity>>> getWorkingDirectoryStatus() async {
    final result = await _runGit(
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
    final result = await _runGit(GitCommands.commitsAheadCount);

    if (result.isLeft) {
      return Left(result.left);
    }

    final count = int.tryParse(result.right.trim()) ?? 0;
    return Right(count);
  }

  Future<Either<GitServiceFailure, String>> push() async {
    final result = await _runGit(GitCommands.gitPush);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data);
      },
    );
  }

  Future<Either<GitServiceFailure, bool>> isRemoteHttps() async {
    final urlResult = await _runGit(GitCommands.remoteGetOrigin);

    return urlResult.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        return Right(data.startsWith("https://"));
      },
    );
  }

  Future<Either<GitServiceFailure, String?>> getRepositorySlug() async {
    final result = await _runGit(GitCommands.remoteVerbose);

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

    await _runGit(args);
  }

  Future<void> stageFile(String filePath) async {
    await _runGit([...GitCommands.gitAdd, filePath]);
  }

  Future<void> unstageFile(String filePath) async {
    await _runGit([...GitCommands.gitRestoreStaged, filePath]);
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

    final result = await _runGit(
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

  List<BranchEntity> parseBranches(
    String stdout, {
    required bool isRemote,
    required Set<String> localBranchNames,
    String? currentBranch,
  }) {
    return stdout.trim().split("\n").where((l) => l.isNotEmpty && !l.contains("->")).map((line) {
      final clean = line.replaceAll("*", "").trim();
      final name = isRemote ? clean.replaceFirst("origin/", "") : clean;

      return BranchEntity(
        name: name,
        isCurrent: !isRemote && name == currentBranch,
        isRemote: isRemote,
        existsLocally: isRemote ? localBranchNames.contains(name) : true,
      );
    }).toList();
  }
}
