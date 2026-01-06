import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';

part 'commit_history_event.dart';
part 'commit_history_state.dart';
part 'commit_history_bloc.mapper.dart';

@LazySingleton()
class CommitHistoryBloc extends Bloc<CommitHistoryEvent, CommitHistoryState> {
  final SharedPreferencesService sharedPreferencesService;
  final GitService gitService;

  CommitHistoryBloc({
    required this.sharedPreferencesService,
    required this.gitService,
  }) : super(CommitHistoryState()) {
    on<LoadCommitHistory>((event, emit) async {
      try {
        emit(state.copyWith(status: CommitHistoryBlocStatus.loading));
        final commits = await gitService.getCommitHistory(limit: event.limit);
        emit(
          state.copyWith(
            commits: commits,
            status: CommitHistoryBlocStatus.loaded,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: CommitHistoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<SelectCommit>((event, emit) async {
      emit(
        state.copyWith(
          selectedCommit: event.commit,
          selectedCommitFiles: [],
          selectedCommitFile: null,
        ),
      );

      final files = await gitService.getCommitFiles(event.commit);

      emit(
        state.copyWith(
          selectedCommitFiles: files,
        ),
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
