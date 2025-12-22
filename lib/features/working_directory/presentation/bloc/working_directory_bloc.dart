import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/git_commands.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
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

  WorkingDirectoryBloc({
    required this.sharedPreferencesService,
    required this.gitService,
  }) : super(WorkingDirectoryState()) {
    on<GetRepositoryStatus>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      if (repositoryPath.isEmpty) return;

      final commandResult = await gitService.runGit(GitCommands.statusPorcelain, repositoryPath);

      final files = gitService.parseGitStatusPorcelain(commandResult);
      final commitsToPush = await gitService.getCommitsAheadCount(repositoryPath);

      emit(
        state.copyWith(
          commitsToPush: commitsToPush,
          files: files,
        ),
      );
    });

    on<PushCommits>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      if (repositoryPath.isEmpty) return;

      try {
        emit(
          state.copyWith(
            status: WorkingDirectoryBlocStatus.loading,
          ),
        );

        await gitService.convertRemoteToSsh(repositoryPath);
        await gitService.runGit(
          GitCommands.gitPush,
          repositoryPath,
        );

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

    on<UpdateWorkingDirectoryStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<AddCommit>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      if (repositoryPath.isEmpty) return;

      final List<String> args = [
        ...GitCommands.gitCommit,
        '-m',
        event.summary,
      ];

      final description = event.description?.trim();
      if (description != null && description.isNotEmpty) {
        args.addAll(['-m', description]);
      }

      await gitService.runGit(args, repositoryPath);

      add(GetRepositoryStatus());
    });

    on<ToggleFileStaging>((event, emit) async {
      final repositoryPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath) ?? "";

      if (repositoryPath.isEmpty) return;

      try {
        if (event.stage) {
          await gitService.runGit(
            [...GitCommands.gitAdd, event.file.path],
            repositoryPath,
          );
        } else {
          await gitService.runGit(
            [...GitCommands.gitRestoreStaged, event.file.path],
            repositoryPath,
          );
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
