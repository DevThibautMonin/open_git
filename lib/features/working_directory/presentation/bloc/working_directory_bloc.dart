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

      emit(
        state.copyWith(
          files: files,
        ),
      );
    });
  }
}
