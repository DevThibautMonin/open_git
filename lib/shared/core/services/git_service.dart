import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/git_commands.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/enums/git_file_status.dart';

@LazySingleton()
class GitService {
  GitService();

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
      throw Exception(result.stderr);
    }

    return result.stdout;
  }

  Future<int> getCommitsAheadCount(String repoPath) async {
    final result = await runGit(
      GitCommands.commitsAheadCount,
      repoPath,
    );

    return int.tryParse(result.trim()) ?? 0;
  }

  Future<void> convertRemoteToSsh(String repoPath) async {
    final remoteUrl = await runGit(
      ['remote', 'get-url', 'origin'],
      repoPath,
    );

    if (remoteUrl.startsWith('https://github.com/')) {
      final sshUrl = remoteUrl.replaceFirst('https://github.com/', 'git@github.com:').replaceAll('\n', '');

      await runGit(
        ['remote', 'set-url', 'origin', sshUrl],
        repoPath,
      );
    }
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

      files.add(
        GitFileEntity(
          path: fileInfo,
          status: status,
          staged: x != ' ',
          selected: x != ' ',
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
