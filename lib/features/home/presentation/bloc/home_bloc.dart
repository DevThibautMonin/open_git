import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/exceptions/git_exceptions.dart';
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

    on<ChooseCloneDirectory>((event, emit) async {
      final path = await FilePicker.platform.getDirectoryPath();

      if (path == null) return;

      emit(
        state.copyWith(
          cloneDestinationPath: path,
        ),
      );
    });

    on<CloneRepositoryUrlChanged>((event, emit) {
      emit(state.copyWith(cloneRepositoryUrl: event.url));
    });

    on<CloneRepositoryConfirmed>((event, emit) async {
      emit(
        state.copyWith(
          status: HomeBlocStatus.cloning,
          cloneProgress: 0,
        ),
      );

      try {
        await gitService.cloneRepositoryWithProgress(
          sshUrl: event.sshUrl,
          targetPath: event.destinationPath,
          onProgress: (progress) {
            emit(
              state.copyWith(
                status: HomeBlocStatus.cloneProgress,
                cloneProgress: progress,
              ),
            );
          },
        );

        emit(
          state.copyWith(
            status: HomeBlocStatus.cloneSuccess,
            cloneProgress: 1.0,
          ),
        );
      } on GitSshHostVerificationFailed {
        emit(
          state.copyWith(
            status: HomeBlocStatus.error,
            errorMessage: 'SSH host not trusted. Run ssh -T git@host first.',
          ),
        );
      } on GitSshPermissionDenied {
        emit(
          state.copyWith(
            status: HomeBlocStatus.error,
            errorMessage: 'SSH permission denied. Add your key to the provider.',
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: HomeBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
