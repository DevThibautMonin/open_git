import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/services/git_commit_history_service.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';

part 'commit_history_event.dart';
part 'commit_history_state.dart';
part 'commit_history_bloc.mapper.dart';

@LazySingleton()
class CommitHistoryBloc extends Bloc<CommitHistoryEvent, CommitHistoryState> {
  final GitCommitHistoryService gitCommitHistoryService;

  CommitHistoryBloc({
    required this.gitCommitHistoryService,
  }) : super(CommitHistoryState()) {
    on<LoadCommitHistory>((event, emit) async {
      emit(state.copyWith(status: CommitHistoryBlocStatus.loading));

      final commitsResult = await gitCommitHistoryService.getCommitHistory(limit: event.limit);

      commitsResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: CommitHistoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              commits: data,
              status: CommitHistoryBlocStatus.loaded,
            ),
          );

          if (data.isNotEmpty) {
            add(SelectCommit(commit: data.first));
          }
        },
      );
    });

    on<SelectCommit>((event, emit) async {
      emit(
        state.copyWith(
          selectedCommit: event.commit,
          selectedCommitFiles: [],
          selectedCommitFile: null,
        ),
      );

      final filesResult = await gitCommitHistoryService.getCommitFiles(event.commit);

      filesResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: CommitHistoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              selectedCommitFiles: data,
              selectedCommitFile: data.isNotEmpty ? data.first : null,
            ),
          );
        },
      );
    });

    on<SelectCommitFile>((event, emit) {
      emit(
        state.copyWith(
          selectedCommitFile: event.filePath,
        ),
      );
    });

    on<ClearSelectedCommitFile>((event, emit) {
      emit(
        state.copyWith(
          selectedCommitFile: null,
          selectedCommit: null,
          selectedCommitFiles: [],
        ),
      );
    });
  }
}
