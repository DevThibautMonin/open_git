import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/exceptions/git_exceptions.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

    on<RetrieveAppVersion>((event, emit) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      emit(state.copyWith(version: packageInfo.version));
    });

    on<UpdateRepositoryStatus>((event, emit) {
      emit(state.copyWith(status: event.status));
    });

    on<SelectRepository>((event, emit) async {
      await gitService.selectRepository();

      final path = sharedPreferencesService.getString(
        SharedPreferencesKeys.repositoryPath,
      );

      if (path == null || path.isEmpty) return;

      emit(
        state.copyWith(
          repositoryPath: path,
          currentRepositoryName: repoNameFromPath(path),
          status: RepositoryBlocStatus.repositorySelected,
        ),
      );
    });

    on<InitLastRepository>((event, emit) async {
      final path = sharedPreferencesService.getString(
        SharedPreferencesKeys.repositoryPath,
      );

      if (path == null || path.isEmpty) return;

      emit(
        state.copyWith(
          repositoryPath: path,
          currentRepositoryName: repoNameFromPath(path),
          status: RepositoryBlocStatus.repositorySelected,
        ),
      );
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

    on<SetRepositoryViewMode>((event, emit) {
      emit(
        state.copyWith(
          repositoryViewMode: event.mode,
        ),
      );
    });

    on<CloneRepositoryConfirmed>((event, emit) async {
      emit(
        state.copyWith(
          status: RepositoryBlocStatus.cloning,
          cloneProgress: 0,
        ),
      );

      try {
        await gitService.ensureDirectoryIsEmpty(event.destinationPath);
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
      } on DirectoryNotEmptyFailure {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: "The target directory must be empty.",
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
