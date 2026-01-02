import "dart:convert";
import "dart:io";
import "package:file_picker/file_picker.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/exceptions/git_exceptions.dart";
import "package:open_git/shared/core/logger/log_service.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";

@LazySingleton()
class GitService {
  final LogService logService;
  final SharedPreferencesService sharedPreferencesService;

  GitService({
    required this.logService,
    required this.sharedPreferencesService,
  });

  /// Récupère le chemin du repository actuellement stocké.
  String _getRepoPath() {
    final path = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);
    if (path == null || path.isEmpty) {
      throw Exception("Aucun repository n'est sélectionné.");
    }
    return path;
  }

  Future<void> fetch() async {
    await _runGit(GitCommands.gitFetchPrune);
  }

  Future<String?> selectRepository() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return null;

    await sharedPreferencesService.setString(SharedPreferencesKeys.repositoryPath, path);

    return path;
  }

  Future<void> checkoutRemoteBranch(String branchName) async {
    await _runGit([
      ...GitCommands.checkoutRemoteBranch,
      'origin/$branchName',
    ]);
  }

  Future<Set<String>> getUnpushedCommitShas() async {
    try {
      final output = await _runGit(GitCommands.gitUnpushedCommits);
      return output.split('\n').where((l) => l.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<bool> branchHasUpstream(String branchName) async {
    try {
      await _runGit(
        [
          ...GitCommands.getBranchUpstream,
          "$branchName@{u}",
        ],
        allowedExitCodes: const {0},
      );
      return true;
    } catch (_) {
      return false;
    }
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

  Future<String> _runGit(
    List<String> args, {
    Set<int> allowedExitCodes = const {0},
  }) async {
    final repoPath = _getRepoPath();

    logService.debug("Git command : git $args");

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

  Future<List<String>> getCommitFiles(String commitSha) async {
    final output = await _runGit(
      [
        ...GitCommands.showCommitFiles,
        commitSha,
      ],
    );

    return output.split("\n").where((line) => line.trim().isNotEmpty).toList();
  }

  Future<String> getCommitFileDiff({
    required String commitSha,
    required String filePath,
  }) async {
    return await _runGit(
      [
        ...GitCommands.diffCommitFile,
        "$commitSha^",
        commitSha,
        "--",
        filePath,
      ],
      allowedExitCodes: const {0, 1},
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
      'git',
      ['clone', '--progress', sshUrl, targetPath],
    );

    final stderrBuffer = StringBuffer();
    final stdoutBuffer = StringBuffer();

    final progressRegex = GitRegex.cloneRepositoryProgress;

    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      stderrBuffer.writeln(line);

      final match = progressRegex.firstMatch(line);
      if (match != null) {
        onProgress(double.parse(match.group(1)!) / 100);
      }
    });

    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      stdoutBuffer.writeln(line);
    });

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final errorMessage = stderrBuffer.toString().trim();
      throw GitCommandFailed(
        command: 'git clone',
        stderr: errorMessage.isEmpty ? 'Erreur inconnue lors du clone.' : errorMessage,
      );
    }
  }

  Future<bool> hasUpstream() async {
    final result = await Process.run(
      "git",
      GitCommands.getUpstreamState,
      workingDirectory: _getRepoPath(),
    );

    return result.exitCode == 0;
  }

  Future<void> pushOrPublish() async {
    final hasUpstreamBranch = await hasUpstream();

    if (!hasUpstreamBranch) {
      await _runGit(GitCommands.publishBranch);
    } else {
      await push();
    }
  }

  Future<void> ensureDirectoryIsEmpty(String path) async {
    final dir = Directory(path);

    if (await dir.exists()) {
      final isEmpty = await dir.list().isEmpty;
      if (!isEmpty) {
        throw DirectoryNotEmptyFailure(
          message: 'Le dossier cible n’est pas vide.',
        );
      }
    }
  }

  Future<List<BranchEntity>> getBranches() async {
    final currentBranch = (await _runGit(
      GitCommands.gitCurrentBranch,
    )).trim();

    final localStdout = await _runGit(GitCommands.gitBranch);
    final remoteStdout = await _runGit(GitCommands.gitBranchRemote);

    final localNames = localStdout.split("\n").map((e) => e.replaceAll("*", "").trim()).where((e) => e.isNotEmpty).toSet();

    final localBranches = parseBranches(
      localStdout,
      isRemote: false,
      localBranchNames: localNames,
      currentBranch: currentBranch,
    );

    final remoteBranches = parseBranches(
      remoteStdout,
      isRemote: true,
      localBranchNames: localNames,
    );

    return [
      ...localBranches,
      ...remoteBranches,
    ];
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

  Future<List<GitCommitEntity>> getCommitHistory({int limit = 100}) async {
    final unpushedShas = await getUnpushedCommitShas();

    final output = await _runGit(
      [
        "log",
        "--pretty=format:%H|%an|%ad|%s",
        "--date=iso",
        "--max-count=$limit",
      ],
    );

    return output.split("\n").where((l) => l.isNotEmpty).map((line) {
      final p = line.split("|");
      final sha = p[0];

      return GitCommitEntity(
        sha: sha,
        author: p[1],
        date: DateTime.parse(p[2]),
        message: p[3],
        isUnpushed: unpushedShas.contains(sha),
      );
    }).toList();
  }

  Future<List<GitFileEntity>> getWorkingDirectoryStatus() async {
    final output = await _runGit(
      GitCommands.statusPorcelain,
      allowedExitCodes: const {0, 1},
    );
    return parseGitStatusPorcelain(output);
  }

  Future<int> getCommitsAheadCount() async {
    final result = await _runGit(GitCommands.commitsAheadCount);
    return int.tryParse(result.trim()) ?? 0;
  }

  Future<void> push() async {
    await _runGit(GitCommands.gitPush);
  }

  Future<bool> isRemoteHttps() async {
    final url = await _runGit(GitCommands.remoteGetOrigin);
    return url.startsWith("https://");
  }

  Future<String?> getRepositorySlug() async {
    final output = await _runGit(GitCommands.remoteVerbose);

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

  Future<String> getFileDiff({
    required String filePath,
    required GitFileStatus status,
    required bool staged,
  }) async {
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

    return await _runGit(
      args,
      allowedExitCodes: const {0, 1},
    );
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
