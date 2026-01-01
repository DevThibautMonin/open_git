import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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

    on<AskForRenamingBranch>((event, emit) async {
      final hasUpstream = await gitService.branchHasUpstream(event.branch.name);

      emit(
        state.copyWith(
          selectedBranch: event.branch,
          selectedBranchHasUpstream: hasUpstream,
          status: BranchesBlocStatus.askForRenamingBranch,
        ),
      );
    });

    on<UpdateSelectedBranch>((event, emit) {
      emit(state.copyWith(selectedBranch: event.branch));
    });

    on<DeleteBranch>((event, emit) async {
      if (event.branch.isCurrent) {
        emit(
          state.copyWith(
            status: BranchesBlocStatus.error,
            errorMessage: "You can't delete current branch",
          ),
        );
        return;
      }

      await gitService.deleteBranch(event.branch.name);
      add(GetRepositoryBranches());
    });

    on<RenameBranch>((event, emit) async {
      try {
        await gitService.renameBranch(
          oldName: event.branch.name,
          newName: event.newName,
        );

        add(GetRepositoryBranches());

        emit(state.copyWith(status: BranchesBlocStatus.branchRenamed));
      } catch (e) {
        emit(
          state.copyWith(
            status: BranchesBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<SwitchToBranch>((event, emit) async {
      await gitService.switchBranch(event.branch.name);
      add(GetRepositoryBranches());
    });

    on<GetRepositoryBranches>((event, emit) async {
      final branches = await gitService.getBranches();
      emit(
        state.copyWith(
          branches: branches,
          status: BranchesBlocStatus.branchesRetrieved,
        ),
      );
    });

    on<CreateNewBranchAndCheckout>((event, emit) async {
      await gitService.createBranchAndCheckout(event.branchName);
      add(GetRepositoryBranches());
      emit(state.copyWith(status: BranchesBlocStatus.branchCreated));
    });
  }
}
