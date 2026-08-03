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
    final localResult = await commandRunner.run(
      GitCommands.listLocalBranchesWithTracking,
    );

    if (localResult.isLeft) {
      return Left(localResult.left);
    }

    final remoteResult = await commandRunner.run(GitCommands.gitRemoteBranches);

    if (remoteResult.isLeft) {
      return Left(remoteResult.left);
    }

    final localStdout = localResult.right;
    final remoteStdout = remoteResult.right;

    final remoteFullNames = remoteStdout
        .split("\n")
        .where((l) => l.isNotEmpty && !l.contains("->"))
        .map((l) => l.trim())
        .toSet();

    final remoteNames = remoteFullNames
        .map((l) => l.replaceFirst("origin/", "").trim())
        .where((l) => l.isNotEmpty)
        .toSet();

    final localBranchLines = localStdout
        .split("\n")
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);

    final localBranches = localBranchLines.map((line) {
      final parts = line.split("|");
      final name = parts.isNotEmpty ? parts[0].trim() : "";
      final isCurrent = parts.length > 1 && parts[1].trim() == "*";
      final upstream = parts.length > 2 ? parts[2].trim() : "";
      final tracking = parts.length > 3 ? parts[3].trim() : "";
      final syncStatus = _parseTrackingStatus(tracking);
      final deletedOnRemote =
          !isCurrent &&
          upstream.isNotEmpty &&
          !remoteFullNames.contains(upstream);

      if (name.isEmpty) {
        return null;
      }

      return BranchEntity(
        name: name,
        isCurrent: isCurrent,
        isRemote: false,
        existsLocally: true,
        deletedOnRemote: deletedOnRemote,
        commitsAhead: syncStatus.ahead,
        commitsBehind: syncStatus.behind,
      );
    }).nonNulls;

    final localNames = localBranches.map((branch) => branch.name).toSet();

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
    final result = await commandRunner.run([
      ...GitCommands.switchToBranch,
      name,
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, void>> createBranchAndCheckout(
    String name,
  ) async {
    final result = await commandRunner.run([
      ...GitCommands.checkoutBranch,
      name,
    ]);

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

  Future<Either<GitServiceFailure, void>> checkoutRemoteBranch(
    String branchName,
  ) async {
    final result = await commandRunner.run([
      ...GitCommands.checkoutRemoteBranch,
      "origin/$branchName",
    ]);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<GitServiceFailure, bool>> branchHasUpstream(
    String branchName,
  ) async {
    final result = await commandRunner.run(
      [...GitCommands.getBranchUpstreamState, "refs/heads/$branchName"],
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.trim().isNotEmpty),
    );
  }

  Future<Either<GitServiceFailure, Set<String>>> getRemoteBranchNames() async {
    final result = await commandRunner.run(GitCommands.gitRemoteBranches);

    return result.map(
      (output) {
        return output
            .split("\n")
            .map((l) => l.replaceFirst("origin/", "").trim())
            .where((l) => l.isNotEmpty)
            .toSet();
      },
    );
  }

  ({int ahead, int behind}) _parseTrackingStatus(String tracking) {
    final status = tracking.replaceAll("[", "").replaceAll("]", "");
    int ahead = 0;
    int behind = 0;

    for (final segment in status.split(",")) {
      final value = segment.trim();

      if (value.startsWith("ahead ")) {
        ahead = int.tryParse(value.replaceFirst("ahead ", "")) ?? 0;
      }

      if (value.startsWith("behind ")) {
        behind = int.tryParse(value.replaceFirst("behind ", "")) ?? 0;
      }
    }

    return (ahead: ahead, behind: behind);
  }
}
