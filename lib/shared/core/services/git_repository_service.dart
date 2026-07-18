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
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitRepositoryService {
  static const int maxRecentRepositories = 20;

  final SharedPreferencesService sharedPreferencesService;
  final GitCommandRunner commandRunner;

  GitRepositoryService({
    required this.sharedPreferencesService,
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, bool>> repositoryExists() async {
    final path = sharedPreferencesService.getString(
      SharedPreferencesKeys.repositoryPath,
    );

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

    return setRepositoryPath(path);
  }

  Future<Either<GitServiceFailure, String?>> initRepository() async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path == null) {
      return Left(RepositoryNotSelectedFailure());
    }

    final dir = Directory(path);
    if (!await dir.exists()) {
      return Left(
        RepositoryPathInvalidFailure(
          command: path,
        ),
      );
    }

    final initResult = await commandRunner.runInDirectory(
      GitCommands.gitInit,
      workingDirectory: path,
    );

    if (initResult.isLeft) {
      return Left(initResult.left);
    }

    return setRepositoryPath(path);
  }

  Future<Either<GitServiceFailure, String>> setRepositoryPath(
    String path,
  ) async {
    final dir = Directory(path);

    if (!await dir.exists()) {
      await removeRecentRepositoryPath(path);
      return Left(
        RepositoryPathInvalidFailure(
          command: path,
        ),
      );
    }

    await sharedPreferencesService.setString(
      SharedPreferencesKeys.repositoryPath,
      path,
    );
    await addRecentRepositoryPath(path);

    return Right(path);
  }

  List<String> getRecentRepositoryPaths() {
    final raw = sharedPreferencesService.getString(
      SharedPreferencesKeys.recentRepositoryPaths,
    );

    if (raw == null || raw.isEmpty) return const [];

    try {
      final data = jsonDecode(raw);
      if (data is! List) return const [];

      return data.whereType<String>().toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> addRecentRepositoryPath(String path) async {
    final paths = [
      path,
      ...getRecentRepositoryPaths().where((recentPath) {
        return recentPath != path;
      }),
    ].take(maxRecentRepositories).toList(growable: false);

    await sharedPreferencesService.setString(
      SharedPreferencesKeys.recentRepositoryPaths,
      jsonEncode(paths),
    );
  }

  Future<void> removeRecentRepositoryPath(String path) async {
    final paths = getRecentRepositoryPaths()
        .where((recentPath) {
          return recentPath != path;
        })
        .toList(growable: false);

    await sharedPreferencesService.setString(
      SharedPreferencesKeys.recentRepositoryPaths,
      jsonEncode(paths),
    );
  }

  Future<Either<GitServiceFailure, void>> cloneRepositoryWithProgress({
    required String sshUrl,
    required String targetPath,
    required void Function(double progress) onProgress,
  }) async {
    final progressRegex = GitRegex.cloneRepositoryProgress;

    final cloneResult = await commandRunner.runStreaming(
      ["clone", "--progress", sshUrl, targetPath],
      onStdErrLine: (line) {
        final match = progressRegex.firstMatch(line);
        if (match != null) {
          onProgress(double.parse(match.group(1)!) / 100);
        }
      },
    );

    if (cloneResult.isLeft) {
      return Left(cloneResult.left);
    }

    return const Right(null);
  }

  Future<Either<GitServiceFailure, bool>> ensureDirectoryIsEmpty(
    String path,
  ) async {
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
