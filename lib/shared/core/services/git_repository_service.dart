import "dart:convert";
import "dart:io";
import "package:either_dart/either.dart";
import "package:file_picker/file_picker.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_regex.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitRepositoryService {
  final SharedPreferencesService sharedPreferencesService;

  GitRepositoryService({
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

  Future<Either<GitServiceFailure, String?>> selectRepository() async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path == null) {
      return Left(RepositoryNotSelectedFailure());
    }

    await sharedPreferencesService.setString(SharedPreferencesKeys.repositoryPath, path);

    return Right(path);
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
}
