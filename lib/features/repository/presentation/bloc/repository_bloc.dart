import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/exceptions/git_exceptions.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:path/path.dart' as p;

part 'repository_event.dart';
part 'repository_state.dart';
part 'repository_bloc.mapper.dart';

@LazySingleton()
class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final GitService gitService;
  final SharedPreferencesService sharedPreferencesService;

  RepositoryBloc({
    required this.gitService,
    required this.sharedPreferencesService,
  }) : super(RepositoryState()) {
    String repoNameFromPath(String path) => p.basename(path);

    on<UpdateRepositoryStatus>((event, emit) {
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
          status: RepositoryBlocStatus.repositorySelected,
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
            status: RepositoryBlocStatus.repositorySelected,
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
          status: RepositoryBlocStatus.cloning,
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
                status: RepositoryBlocStatus.cloneProgress,
                cloneProgress: progress,
              ),
            );
          },
        );

        emit(
          state.copyWith(
            status: RepositoryBlocStatus.cloneSuccess,
            cloneProgress: 1.0,
          ),
        );
      } on GitSshHostVerificationFailed {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: 'SSH host not trusted. Run ssh -T git@host first.',
          ),
        );
      } on GitSshPermissionDenied {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: 'SSH permission denied. Add your key to the provider.',
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
