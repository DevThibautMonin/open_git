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
    String repoNameFromPath(String fullPath) {
      return p.basename(fullPath);
    }

    on<SelectRepository>((event, emit) async {
      final repositoryPath = await gitService.selectRepoDirectory() ?? "";
      final repositoryName = repoNameFromPath(repositoryPath);

      await sharedPreferencesService.setString(SharedPreferencesKeys.repositoryPath, repositoryPath);

      emit(
        state.copyWith(
          currentRepositoryName: repositoryName,
          repositoryPath: repositoryPath,
          status: HomeBlocStatus.repositorySelected,
        ),
      );
    });
  }
}
