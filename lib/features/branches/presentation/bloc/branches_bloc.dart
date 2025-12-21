import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/git_commands.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';

part 'branches_event.dart';
part 'branches_state.dart';
part 'branches_bloc.mapper.dart';

@LazySingleton()
class BranchesBloc extends Bloc<BranchesEvent, BranchesState> {
  final GitService gitService;
  final SharedPreferencesService sharedPreferencesService;

  BranchesBloc({
    required this.gitService,
    required this.sharedPreferencesService,
  }) : super(BranchesState()) {
    on<UpdateBranchesStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<DeleteBranch>((event, emit) async {
      final repoPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? '';
      if (repoPath.isEmpty) return;

      if (event.branch.isCurrent) {
        return emit(
          state.copyWith(
            status: BranchesBlocStatus.error,
            errorMessage: "You can't delete current branch !",
          ),
        );
      }

      await gitService.runGit([...GitCommands.deleteBranch, event.branch.name], repoPath);

      add(GetRepositoryBranches());
    });

    on<SwitchToBranch>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      await gitService.runGit(
        [...GitCommands.switchToBranch, event.branch.name],
        repositoryPath,
      );

      final updatedBranches = state.branches
          .map(
            (branch) => branch.copyWith(
              isCurrent: branch.name == event.branch.name,
            ),
          )
          .toList();

      emit(
        state.copyWith(
          branches: updatedBranches,
        ),
      );
    });

    List<BranchEntity> parseBranches(String stdout) {
      return stdout.trim().split('\n').where((line) => line.isNotEmpty).map((line) {
        final parts = line.split('|');
        return BranchEntity(
          name: parts[0],
          isCurrent: parts.length > 1 && parts[1] == '*',
        );
      }).toList();
    }

    on<GetRepositoryBranches>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";
      if (repositoryPath.isNotEmpty) {
        final commandResult = await gitService.runGit(GitCommands.listBranches, repositoryPath);
        final branches = parseBranches(commandResult);
        emit(
          state.copyWith(
            branches: branches,
            status: BranchesBlocStatus.branchesRetrieved,
          ),
        );
      }
    });

    on<CreateNewBranchAndCheckout>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";
      if (repositoryPath.isNotEmpty) {
        await gitService.runGit([...GitCommands.checkoutBranch, event.branchName], repositoryPath);
        add(GetRepositoryBranches());
        emit(
          state.copyWith(
            status: BranchesBlocStatus.branchCreated,
          ),
        );
      }
    });
  }
}
