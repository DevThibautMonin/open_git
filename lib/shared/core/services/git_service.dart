import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/exceptions/git_exceptions.dart";
import "package:open_git/shared/core/logger/log_service.dart";
import "package:open_git/shared/core/services/macos_security_scoped_service.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";

@LazySingleton()
class GitService {
  final LogService logService;
  final MacOSSecurityScopedService macOSSecurityScopedService;
  final SharedPreferencesService sharedPreferencesService;

  GitService({
    required this.logService,
    required this.macOSSecurityScopedService,
    required this.sharedPreferencesService,
  });

  /// Temporarily grants sandboxed access to the repository using a security-scoped bookmark,
  /// executes the given action with the resolved path, then always releases the access.
  Future<T> withRepoAccess<T>(Future<T> Function(String path) fn) async {
    final bookmark = _loadBookmark();
    final path = await macOSSecurityScopedService.resolveBookmark(bookmark);

    try {
      return await fn(path);
    } finally {
      await macOSSecurityScopedService.stopAccess(path);
    }
  }

  Uint8List _loadBookmark() {
    final data = sharedPreferencesService.getBytes(
      SharedPreferencesKeys.repositoryBookmark,
    );
    if (data == null) {
      throw Exception("No repository bookmark found");
    }
    return Uint8List.fromList(data);
  }

  Future<String?> selectRepository() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return null;

    final bookmark = await macOSSecurityScopedService.createBookmark(path);

    await sharedPreferencesService.setBytes(
      SharedPreferencesKeys.repositoryBookmark,
      bookmark,
    );
    await sharedPreferencesService.setString(
      SharedPreferencesKeys.repositoryPath,
      path,
    );

    return path;
  }

  Future<String> _runGit(
    List<String> args,
    String repoPath, {
    Set<int> allowedExitCodes = const {0},
  }) async {
    final result = await Process.run(
      "git",
      args,
      workingDirectory: repoPath,
    );

    if (!allowedExitCodes.contains(result.exitCode)) {
      logService.error("❌ git ${args.join(" ")}");
      logService.error(result.stderr.toString());
      throw _mapGitError(result.stderr.toString(), args);
    }

    return result.stdout.toString();
  }

  GitException _mapGitError(String stderr, List<String> args) {
    final error = stderr.toLowerCase();

    if (error.contains("host key verification failed")) {
      return GitSshHostVerificationFailed();
    }
    if (error.contains("permission denied (publickey)")) {
      return GitSshPermissionDenied();
    }
    if (error.contains("could not read username")) {
      return GitHttpsAuthRequired();
    }

    return GitCommandFailed(
      command: "git ${args.join(" ")}",
      stderr: stderr,
    );
  }

  Future<void> cloneRepositoryWithProgress({
    required String sshUrl,
    required String targetPath,
    required void Function(double progress) onProgress,
  }) async {
    final process = await Process.start(
      "git",
      ["clone", "--progress", sshUrl, targetPath],
    );

    final buffer = StringBuffer();
    final regex = GitRegex.cloneRepositoryProgress;

    process.stderr.transform(utf8.decoder).listen((line) {
      buffer.write(line);
      final match = regex.firstMatch(line);
      if (match != null) {
        onProgress(double.parse(match.group(1)!) / 100);
      }
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw GitCommandFailed(
        command: "git clone",
        stderr: buffer.toString(),
      );
    }
  }

  Future<List<BranchEntity>> getBranches() {
    return withRepoAccess((path) async {
      final output = await _runGit(GitCommands.listBranches, path);
      return parseBranches(output);
    });
  }

  Future<void> switchBranch(String name) {
    return withRepoAccess((path) async {
      await _runGit([...GitCommands.switchToBranch, name], path);
    });
  }

  Future<void> deleteBranch(String name) {
    return withRepoAccess((path) async {
      await _runGit([...GitCommands.deleteBranch, name], path);
    });
  }

  Future<List<GitCommitEntity>> getCommitHistory({int limit = 100}) {
    return withRepoAccess((path) async {
      final output = await _runGit(
        [
          "log",
          "--pretty=format:%H|%an|%ad|%s",
          "--date=iso",
          "--max-count=$limit",
        ],
        path,
      );

      return output.split("\n").where((l) => l.isNotEmpty).map((line) {
        final p = line.split("|");
        return GitCommitEntity(
          sha: p[0],
          author: p[1],
          date: DateTime.parse(p[2]),
          message: p[3],
        );
      }).toList();
    });
  }

  Future<List<GitFileEntity>> getWorkingDirectoryStatus() {
    return withRepoAccess((path) async {
      final output = await _runGit(
        GitCommands.statusPorcelain,
        path,
        allowedExitCodes: const {0, 1},
      );
      return parseGitStatusPorcelain(output);
    });
  }

  Future<int> getCommitsAheadCount() {
    return withRepoAccess((path) async {
      final result = await _runGit(GitCommands.commitsAheadCount, path);
      return int.tryParse(result.trim()) ?? 0;
    });
  }

  Future<void> push() {
    return withRepoAccess((path) async {
      await _runGit(GitCommands.gitPush, path);
    });
  }

  Future<bool> isRemoteHttps() {
    return withRepoAccess((path) async {
      final url = await _runGit(GitCommands.remoteGetOrigin, path);
      return url.startsWith("https://");
    });
  }

  Future<String?> getRepositorySlug() {
    return withRepoAccess((path) async {
      final output = await _runGit(GitCommands.remoteVerbose, path);

      for (final line in output.split("\n")) {
        if (!line.contains("(fetch)")) continue;
        final parts = line.split(GitRegex.line);
        if (parts.length < 2) continue;

        final url = parts[1];
        final https = GitRegex.httpsMatch.firstMatch(url);
        if (https != null) return https.group(1);

        final ssh = GitRegex.sshMatch.firstMatch(url);
        if (ssh != null) return ssh.group(1);
      }
      return null;
    });
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
  }) {
    return withRepoAccess((path) async {
      final args = [
        ...GitCommands.gitCommit,
        "-m",
        summary,
      ];

      final desc = description?.trim();
      if (desc != null && desc.isNotEmpty) {
        args.addAll(["-m", desc]);
      }

      await _runGit(args, path);
    });
  }

  Future<void> stageFile(String filePath) {
    return withRepoAccess((path) async {
      await _runGit([...GitCommands.gitAdd, filePath], path);
    });
  }

  Future<void> unstageFile(String filePath) {
    return withRepoAccess((path) async {
      await _runGit([...GitCommands.gitRestoreStaged, filePath], path);
    });
  }

  Future<String> getFileDiff({
    required String filePath,
    required GitFileStatus status,
    required bool staged,
  }) {
    return withRepoAccess((repoPath) async {
      late final List<String> args;

      switch (status) {
        case GitFileStatus.untracked:
          args = [
            "diff",
            "--no-index",
            "/dev/null",
            filePath,
          ];
          break;

        case GitFileStatus.added:
          args = [
            "diff",
            "--cached",
            "--unified=3",
            "--",
            filePath,
          ];
          break;

        case GitFileStatus.deleted:
          args = [
            "diff",
            "HEAD",
            "--unified=3",
            "--",
            filePath,
          ];
          break;

        case GitFileStatus.modified:
        case GitFileStatus.renamed:
          args = [
            "diff",
            if (staged) "--cached",
            "--unified=3",
            "--",
            filePath,
          ];
          break;
      }

      return _runGit(
        args,
        repoPath,
        allowedExitCodes: const {0, 1},
      );
    });
  }

  GitFileStatus mapGitFileStatus(String x, String y) {
    if (x == "?" && y == "?") return GitFileStatus.untracked;
    if (x == "A" || y == "A") return GitFileStatus.added;
    if (x == "D" || y == "D") return GitFileStatus.deleted;
    if (x == "R" || y == "R") return GitFileStatus.renamed;
    return GitFileStatus.modified;
  }

  List<BranchEntity> parseBranches(String stdout) {
    return stdout.trim().split("\n").where((l) => l.isNotEmpty).map((line) {
      final p = line.split("|");
      return BranchEntity(
        name: p[0],
        isCurrent: p.length > 1 && p[1] == "*",
      );
    }).toList();
  }
}
