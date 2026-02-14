import 'package:dart_mappable/dart_mappable.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/logger/log_service.dart';
import 'package:open_git/shared/core/services/git_remote_service.dart';
import 'package:open_git/shared/core/services/git_working_directory_service.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/failures/git_service_failure.dart';

part 'working_directory_event.dart';
part 'working_directory_state.dart';
part 'working_directory_bloc.mapper.dart';

@LazySingleton()
class WorkingDirectoryBloc extends Bloc<WorkingDirectoryEvent, WorkingDirectoryState> {
  final GitWorkingDirectoryService gitWorkingDirectoryService;
  final GitRemoteService gitRemoteService;
  final LogService logService;

  WorkingDirectoryBloc({
    required this.gitWorkingDirectoryService,
    required this.gitRemoteService,
    required this.logService,
  }) : super(WorkingDirectoryState()) {
    on<GetRepositoryStatus>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

      final filesResult = await gitWorkingDirectoryService.getWorkingDirectoryStatus();

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

      final upstreamResult = await gitRemoteService.hasUpstream();
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
        final commitsResult = await gitRemoteService.getCommitsAheadCount();

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

      if (file == null) return;

      emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

      final result = await gitWorkingDirectoryService.discardFileChanges(file);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryStatus());
          emit(state.copyWith(status: WorkingDirectoryBlocStatus.initial));
        },
      );
    });

    on<DiscardAllChanges>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.loading));

      final result = await gitWorkingDirectoryService.discardAllChanges();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryStatus());
          emit(state.copyWith(status: WorkingDirectoryBlocStatus.initial));
        },
      );
    });

    on<SelectFile>((event, emit) {
      emit(state.copyWith(selectedFile: event.file));
    });

    on<ToggleAllFilesStaging>((event, emit) async {
      final files = state.files;

      for (final file in files) {
        if (event.stage && !file.staged) {
          final result = await gitWorkingDirectoryService.stageFile(file.path);
          if (result.isLeft) {
            emit(
              state.copyWith(
                status: WorkingDirectoryBlocStatus.error,
                errorMessage: result.left.errorMessage,
              ),
            );
            return;
          }
          logService.debug("Staging : ${file.path}");
        }

        if (!event.stage && file.staged) {
          final result = await gitWorkingDirectoryService.unstageFile(file.path);
          if (result.isLeft) {
            emit(
              state.copyWith(
                status: WorkingDirectoryBlocStatus.error,
                errorMessage: result.left.errorMessage,
              ),
            );
            return;
          }
          logService.debug("Unstaging : ${file.path}");
        }
      }

      add(GetRepositoryStatus());
    });

    on<PushCommits>((event, emit) async {
      emit(state.copyWith(status: WorkingDirectoryBlocStatus.pushingCommits));

      final isHttpsResult = await gitRemoteService.isRemoteHttps();
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
        final slugResult = await gitRemoteService.getRepositorySlug();

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

      final pushResult = await gitRemoteService.pushOrPublish();
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

      final result = await gitWorkingDirectoryService.createCommit(
        summary: event.summary,
        description: event.description,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryStatus());
          emit(state.copyWith(status: WorkingDirectoryBlocStatus.commitsAdded));
        },
      );
    });

    on<ToggleFileStaging>((event, emit) async {
      final Either<GitServiceFailure, void> result;

      if (event.stage) {
        result = await gitWorkingDirectoryService.stageFile(event.file.path);
      } else {
        result = await gitWorkingDirectoryService.unstageFile(event.file.path);
      }

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          add(GetRepositoryStatus());
        },
      );
    });
  }
}
