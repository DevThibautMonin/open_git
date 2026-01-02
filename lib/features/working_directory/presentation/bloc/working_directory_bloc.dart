import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/exceptions/git_exceptions.dart';
import 'package:open_git/shared/core/logger/log_service.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

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
      final files = await gitService.getWorkingDirectoryStatus();
      final hasUpstream = await gitService.hasUpstream();

      int commitsToPush = 0;
      if (hasUpstream) {
        commitsToPush = await gitService.getCommitsAheadCount();
      }

      emit(
        state.copyWith(
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
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      if (repositoryPath.isEmpty) return;

      try {
        emit(state.copyWith(status: WorkingDirectoryBlocStatus.pushingCommits));

        final isHttps = await gitService.isRemoteHttps();
        if (isHttps) {
          final slug = await gitService.getRepositorySlug();
          emit(
            state.copyWith(
              status: WorkingDirectoryBlocStatus.gitRemoteIsHttps,
              gitRemoteCommand: slug != null ? 'git remote set-url origin git@github.com:$slug.git' : null,
            ),
          );
          return;
        }

        await gitService.pushOrPublish();
        add(GetRepositoryStatus());
        emit(state.copyWith(status: WorkingDirectoryBlocStatus.commitsPushed));
      } on GitSshHostVerificationFailed {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.gitSshHostVerificationFailed,
            errorMessage: "SSH host not trusted. Verify the connection to the remote.",
          ),
        );
      } on GitSshPermissionDenied {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.gitSshPermissionDenied,
            errorMessage: "SSH authentication failed. Make sure your key is added.",
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
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
