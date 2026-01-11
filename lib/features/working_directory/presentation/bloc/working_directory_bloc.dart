import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/logger/log_service.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/failures/git_service_failure.dart';

part 'working_directory_event.dart';
part 'working_directory_state.dart';
part 'working_directory_bloc.mapper.dart';

@LazySingleton()
class WorkingDirectoryBloc extends Bloc<WorkingDirectoryEvent, WorkingDirectoryState> {
  final SharedPreferencesService sharedPreferencesService;
  final GitService gitService;
  final LogService logService;

  WorkingDirectoryBloc({
    required this.sharedPreferencesService,
    required this.gitService,
    required this.logService,
  }) : super(WorkingDirectoryState()) {
    on<GetRepositoryStatus>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

      final filesResult = await gitService.getWorkingDirectoryStatus();

      if (filesResult.isLeft) {
        final failure = filesResult.left;

        if (failure is RepositoryDoesntExistsFailure || failure is RepositoryNotSelectedFailure || failure is RepositoryPathInvalidFailure) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.noRepositorySelected,
              files: const [],
              commitsToPush: 0,
              hasUpstream: false,
              selectedFile: null,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: failure.errorMessage,
          ),
        );
        return;
      }

      final files = filesResult.right;

      final upstreamResult = await gitService.hasUpstream();
      if (upstreamResult.isLeft) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: upstreamResult.left.errorMessage,
          ),
        );
        return;
      }

      final hasUpstream = upstreamResult.right;

      int commitsToPush = 0;

      if (hasUpstream) {
        final commitsResult = await gitService.getCommitsAheadCount();

        if (commitsResult.isLeft) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: commitsResult.left.errorMessage,
            ),
          );
          return;
        }

        commitsToPush = commitsResult.right;
      }

      emit(
        state.copyWith(
          status: WorkingDirectoryBlocStatus.loaded,
          files: files,
          hasUpstream: hasUpstream,
          commitsToPush: commitsToPush,
        ),
      );
    });

    on<DiscardFileChanges>((event, emit) async {
      final GitFileEntity? file = event.file;
      try {
        emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

        if (file != null) {
          await gitService.discardFileChanges(file);

          add(GetRepositoryStatus());

          emit(state.copyWith(status: WorkingDirectoryBlocStatus.initial));
        }
      } catch (e) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<DiscardAllChanges>((event, emit) async {
      try {
        emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

        await gitService.discardAllChanges();

        add(GetRepositoryStatus());

        emit(state.copyWith(status: WorkingDirectoryBlocStatus.initial));
      } catch (e) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<SelectFile>((event, emit) {
      emit(state.copyWith(selectedFile: event.file));
    });

    on<ToggleAllFilesStaging>((event, emit) async {
      try {
        final files = state.files;

        for (final file in files) {
          if (event.stage && !file.staged) {
            await gitService.stageFile(file.path);
            logService.debug("Staging : ${file.path}");
          }

          if (!event.stage && file.staged) {
            await gitService.unstageFile(file.path);
            logService.debug("Unstaging : ${file.path}");
          }
        }

        add(GetRepositoryStatus());
      } catch (e) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<PushCommits>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.pushingCommits));

      final isHttpsResult = await gitService.isRemoteHttps();
      if (isHttpsResult.isLeft) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: isHttpsResult.left.errorMessage,
          ),
        );
        return;
      }

      final isHttps = isHttpsResult.right;

      if (isHttps) {
        final slugResult = await gitService.getRepositorySlug();

        if (slugResult.isLeft) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: slugResult.left.errorMessage,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.gitRemoteIsHttps,
            gitRemoteCommand: slugResult.right != null ? 'git remote set-url origin git@github.com:${slugResult.right}.git' : null,
          ),
        );
        return;
      }

      final pushResult = await gitService.pushOrPublish();
      if (pushResult.isLeft) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: pushResult.left.errorMessage,
          ),
        );
        return;
      }

      add(GetRepositoryStatus());

      emit(state.copyWith(status: WorkingDirectoryBlocStatus.commitsPushed));
    });

    on<UpdateWorkingDirectoryStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<ClearSelectedFile>((event, emit) {
      emit(
        state.copyWith(
          selectedFile: null,
        ),
      );
    });

    on<AddCommit>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.addingCommits));

      await gitService.createCommit(
        summary: event.summary,
        description: event.description,
      );

      add(GetRepositoryStatus());
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.commitsAdded));
    });

    on<ToggleFileStaging>((event, emit) async {
      try {
        if (event.stage) {
          await gitService.stageFile(event.file.path);
        } else {
          await gitService.unstageFile(event.file.path);
        }

        add(GetRepositoryStatus());
      } catch (e) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
