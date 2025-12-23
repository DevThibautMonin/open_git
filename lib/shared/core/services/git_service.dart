import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/git_commands.dart';
import 'package:open_git/shared/core/exceptions/git_exceptions.dart';
import 'package:open_git/shared/core/logger/log_service.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/enums/git_file_status.dart';

@LazySingleton()
class GitService {
  final LogService logService;

  GitService({
    required this.logService,
  });

  GitException _mapGitError(String stderr, List<String> args) {
    final error = stderr.toLowerCase();

    logService.error(error);

    if (error.contains('host key verification failed')) {
      return GitSshHostVerificationFailed();
    }

    if (error.contains('permission denied (publickey)')) {
      return GitSshPermissionDenied();
    }

    if (error.contains('could not read username')) {
      return GitHttpsAuthRequired();
    }

    return GitCommandFailed(
      command: 'git ${args.join(' ')}',
      stderr: stderr,
    );
  }

  Future<String?> selectRepoDirectory() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath();
    return selectedPath;
  }

  Future<String> runGit(List<String> args, String repoPath) async {
    final result = await Process.run(
      'git',
      args,
      workingDirectory: repoPath,
    );

    if (result.exitCode != 0) {
      throw _mapGitError(result.stderr.toString(), args);
    }

    return result.stdout.toString();
  }

  Future<int> getCommitsAheadCount(String repoPath) async {
    final result = await runGit(
      GitCommands.commitsAheadCount,
      repoPath,
    );

    return int.tryParse(result.trim()) ?? 0;
  }

  Future<List<GitCommitEntity>> getCommitHistory(
    String repoPath, {
    int limit = 100,
  }) async {
    final output = await runGit(
      [
        'log',
        '--pretty=format:%H|%an|%ad|%s',
        '--date=iso',
        '--max-count=$limit',
      ],
      repoPath,
    );

    final lines = output.split('\n');

    return lines.map((line) {
      final parts = line.split('|');

      return GitCommitEntity(
        sha: parts[0],
        author: parts[1],
        date: DateTime.parse(parts[2]),
        message: parts[3],
      );
    }).toList();
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
    final progressRegex = RegExp(r'Receiving objects:\s+(\d+)%');

    process.stderr.transform(utf8.decoder).listen((line) {
      stderrBuffer.write(line);

      final match = progressRegex.firstMatch(line);
      if (match != null) {
        final percent = double.parse(match.group(1)!);
        onProgress(percent / 100);
      }
    });

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final stderr = stderrBuffer.toString().toLowerCase();

      if (stderr.contains('host key verification failed')) {
        throw GitSshHostVerificationFailed();
      }

      if (stderr.contains('permission denied (publickey)')) {
        throw GitSshPermissionDenied();
      }

      throw GitCommandFailed(
        command: 'git clone',
        stderr: stderrBuffer.toString(),
      );
    }
  }

  Future<String?> getRepositorySlug(String repoPath) async {
    final output = await runGit(['remote', '-v'], repoPath);

    final lines = output.split('\n');

    for (final line in lines) {
      if (!line.contains('(fetch)')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      final url = parts[1];

      // HTTPS (support / et :)
      final httpsMatch = RegExp(
        r'https://[^/:]+[:/]+([^/]+/[^/]+?)(\.git)?$',
      ).firstMatch(url);

      if (httpsMatch != null) {
        return httpsMatch.group(1);
      }

      // SSH
      final sshMatch = RegExp(
        r'git@[^:]+:([^/]+/[^/]+?)(\.git)?$',
      ).firstMatch(url);

      if (sshMatch != null) {
        return sshMatch.group(1);
      }
    }

    return null;
  }

  Future<bool> isRemoteHttps(String repoPath) async {
    final remoteUrl = await runGit(
      ['remote', 'get-url', 'origin'],
      repoPath,
    );

    return remoteUrl.startsWith('https://');
  }

  GitFileStatus mapGitFileStatus(String x, String y) {
    // Untracked
    if (x == '?' && y == '?') {
      return GitFileStatus.untracked;
    }

    // Added
    if (x == 'A' || y == 'A') {
      return GitFileStatus.added;
    }

    // Deleted
    if (x == 'D' || y == 'D') {
      return GitFileStatus.deleted;
    }

    // Renamed
    if (x == 'R' || y == 'R') {
      return GitFileStatus.renamed;
    }

    // Modified (cas le plus courant)
    return GitFileStatus.modified;
  }

  List<GitFileEntity> parseGitStatusPorcelain(String output) {
    final List<GitFileEntity> files = [];

    final lines = output.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // Exemple : " M lib/file.dart"
      final String x = line[0];
      final String y = line[1];
      final String fileInfo = line.substring(3).trim();

      // Renommage : R  old.dart -> new.dart
      if (fileInfo.contains('->')) {
        final parts = fileInfo.split('->').map((e) => e.trim()).toList();

        files.add(
          GitFileEntity(
            path: parts[1],
            status: GitFileStatus.renamed,
            staged: x != ' ',
          ),
        );
        continue;
      }

      final GitFileStatus status = mapGitFileStatus(x, y);

      bool staged = status == GitFileStatus.untracked ? false : x != ' ';

      files.add(
        GitFileEntity(
          path: fileInfo,
          status: status,
          staged: staged,
        ),
      );
    }

    return files;
  }

  List<BranchEntity> parseBranches(String stdout) {
    return stdout.trim().split('\n').where((line) => line.isNotEmpty).map((line) {
      final parts = line.split('|');
      return BranchEntity(
        name: parts[0],
        isCurrent: parts.length > 1 && parts[1] == '*',
      );
    }).toList();
  }
}
