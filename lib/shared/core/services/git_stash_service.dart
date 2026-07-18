import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/git_stash_entity.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitStashService {
  final GitCommandRunner commandRunner;

  GitStashService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, List<GitStashEntity>>> getStashes() async {
    final result = await commandRunner.run(GitCommands.gitStashList);

    return result.fold(
      (failure) => Left(failure),
      (output) => Right(_parseStashes(output)),
    );
  }

  Future<Either<GitServiceFailure, void>> createStash({
    String? message,
  }) async {
    final args = [...GitCommands.gitStashPush];
    final cleanMessage = message?.trim();

    if (cleanMessage != null && cleanMessage.isNotEmpty) {
      args.addAll(["-m", cleanMessage]);
    }

    final result = await commandRunner.run(args);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> applyStash(String reference) async {
    final result = await commandRunner.run([
      ...GitCommands.gitStashApply,
      reference,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> popStash(String reference) async {
    final result = await commandRunner.run([
      ...GitCommands.gitStashPop,
      reference,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> dropStash(String reference) async {
    final result = await commandRunner.run([
      ...GitCommands.gitStashDrop,
      reference,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  List<GitStashEntity> _parseStashes(String output) {
    return output
        .split("\n")
        .where((line) {
          return line.trim().isNotEmpty;
        })
        .map((line) {
          final parts = line.split("\x1f");
          return GitStashEntity(
            reference: parts.isNotEmpty ? parts[0].trim() : "",
            age: parts.length > 1 ? parts[1].trim() : "",
            message: parts.length > 2 ? parts.sublist(2).join(" ").trim() : "",
          );
        })
        .where((stash) {
          return stash.reference.isNotEmpty;
        })
        .toList(growable: false);
  }
}
