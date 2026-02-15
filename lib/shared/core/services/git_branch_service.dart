import "package:either_dart/either.dart";
import "package:injectable/injectable.dart";
import "package:open_git/shared/core/constants/git_commands.dart";
import "package:open_git/shared/core/services/git_command_runner.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/domain/failures/git_service_failure.dart";

@LazySingleton()
class GitBranchService {
  final GitCommandRunner commandRunner;

  GitBranchService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, List<BranchEntity>>> getBranches() async {
    final currentBranchResult = await commandRunner.run(GitCommands.gitCurrentBranch);

    if (currentBranchResult.isLeft) {
      return Left(currentBranchResult.left);
    }

    final localResult = await commandRunner.run(GitCommands.gitBranch);

    if (localResult.isLeft) {
      return Left(localResult.left);
    }

    final remoteResult = await commandRunner.run(GitCommands.gitRemoteBranches);

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

  Future<Either<GitServiceFailure, void>> switchBranch(String name) async {
    final result = await commandRunner.run([...GitCommands.switchToBranch, name]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> createBranchAndCheckout(String name) async {
    final result = await commandRunner.run([...GitCommands.checkoutBranch, name]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> deleteBranch(String name) async {
    final result = await commandRunner.run([...GitCommands.deleteBranch, name]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> renameBranch({
    required String oldName,
    required String newName,
  }) async {
    final result = await commandRunner.run([
      ...GitCommands.renameBranch,
      oldName,
      newName,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> checkoutRemoteBranch(String branchName) async {
    final result = await commandRunner.run([
      ...GitCommands.checkoutRemoteBranch,
      'origin/$branchName',
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, bool>> branchHasUpstream(String branchName) async {
    final result = await commandRunner.run(
      [...GitCommands.getBranchUpstream, "$branchName@{u}"],
      allowedExitCodes: const {0, 1},
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  Future<Either<GitServiceFailure, Set<String>>> getRemoteBranchNames() async {
    final result = await commandRunner.run(GitCommands.gitRemoteBranches);

    return result.map(
      (output) {
        return output.split('\n').map((l) => l.replaceFirst('origin/', '').trim()).where((l) => l.isNotEmpty).toSet();
      },
    );
  }
}
