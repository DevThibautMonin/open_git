import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';

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
}
