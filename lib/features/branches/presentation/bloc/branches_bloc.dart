import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/services/git_branch_service.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/domain/entities/branch_group_entity.dart';

part 'branches_event.dart';
part 'branches_state.dart';
part 'branches_bloc.mapper.dart';

@LazySingleton()
class BranchesBloc extends Bloc<BranchesEvent, BranchesState> {
  final GitBranchService gitBranchService;

  BranchesBloc({
    required this.gitBranchService,
  }) : super(BranchesState()) {
    on<UpdateBranchesStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<CheckoutRemoteBranch>((event, emit) async {
      final result = await gitBranchService.checkoutRemoteBranch(event.branch.name);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryBranches());
        },
      );
    });

    on<AskForRenamingBranch>((event, emit) async {
      final upstreamResult = await gitBranchService.branchHasUpstream(event.branch.name);

      if (upstreamResult.isLeft) {
        emit(
          state.copyWith(
            status: BranchesBlocStatus.error,
            errorMessage: upstreamResult.left.errorMessage,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          selectedBranch: event.branch,
          selectedBranchHasUpstream: upstreamResult.right,
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

      final result = await gitBranchService.deleteBranch(event.branch.name);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryBranches());
        },
      );
    });

    on<RenameBranch>((event, emit) async {
      final result = await gitBranchService.renameBranch(
        oldName: event.branch.name,
        newName: event.newName,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryBranches());
          emit(state.copyWith(status: BranchesBlocStatus.branchRenamed));
        },
      );
    });

    on<SwitchToBranch>((event, emit) async {
      final result = await gitBranchService.switchBranch(event.branch.name);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryBranches());
        },
      );
    });

    on<GetRepositoryBranches>((event, emit) async {
      final branchesResult = await gitBranchService.getBranches();

      branchesResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              branches: data,
              status: BranchesBlocStatus.branchesRetrieved,
            ),
          );
        },
      );
    });

    on<CreateNewBranchAndCheckout>((event, emit) async {
      final result = await gitBranchService.createBranchAndCheckout(event.branchName);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BranchesBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryBranches());
          emit(state.copyWith(status: BranchesBlocStatus.branchCreated));
        },
      );
    });
  }
}
