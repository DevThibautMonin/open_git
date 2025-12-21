import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:path/path.dart' as p;

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.mapper.dart';

@LazySingleton()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GitService gitService;
  final SharedPreferencesService sharedPreferencesService;

  HomeBloc({
    required this.gitService,
    required this.sharedPreferencesService,
  }) : super(HomeState()) {
    String repoNameFromPath(String path) => p.basename(path);

    on<UpdateHomeStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<SelectRepository>((event, emit) async {
      final repositoryPath = await gitService.selectRepoDirectory();
      if (repositoryPath == null || repositoryPath.isEmpty) return;

      await sharedPreferencesService.setString(SharedPreferencesKeys.repositoryPath, repositoryPath);

      emit(
        state.copyWith(
          repositoryPath: repositoryPath,
          currentRepositoryName: repoNameFromPath(repositoryPath),
          status: HomeBlocStatus.repositorySelected,
        ),
      );
    });

    on<InitLastRepository>((event, emit) async {
      final lastPath = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);

      if (lastPath != null && lastPath.isNotEmpty) {
        emit(
          state.copyWith(
            repositoryPath: lastPath,
            currentRepositoryName: repoNameFromPath(lastPath),
            status: HomeBlocStatus.repositorySelected,
          ),
        );
      }
    });
  }
}
