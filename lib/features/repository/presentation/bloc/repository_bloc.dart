import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
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
      final path = sharedPreferencesService.getString(SharedPreferencesKeys.repositoryPath);

      if (path == null || path.isEmpty) {
        return;
      }

      final existsResult = await gitService.repositoryExists();

      if (existsResult.isLeft) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: existsResult.left.errorMessage,
          ),
        );
        return;
      }

      final exists = existsResult.right;

      if (!exists) {
        await sharedPreferencesService.setString(
          SharedPreferencesKeys.repositoryPath,
          '',
        );

        emit(
          state.copyWith(
            repositoryPath: '',
            currentRepositoryName: '',
            status: RepositoryBlocStatus.repositoryDeleted,
            errorMessage: 'The previously opened repository no longer exists.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          repositoryPath: path,
          currentRepositoryName: p.basename(path),
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

    on<FetchRepository>((event, emit) async {
      try {
        emit(state.copyWith(status: RepositoryBlocStatus.fetching));

        await gitService.fetch();

        emit(state.copyWith(status: RepositoryBlocStatus.fetched));
      } catch (e) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<CloneRepositoryConfirmed>((event, emit) async {
      emit(
        state.copyWith(
          status: RepositoryBlocStatus.cloning,
          cloneProgress: 0,
        ),
      );

      final dirResult = await gitService.ensureDirectoryIsEmpty(event.destinationPath);

      if (dirResult.isLeft) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: dirResult.left.errorMessage,
          ),
        );
        return;
      }

      final cloneResult = await gitService.cloneRepositoryWithProgress(
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

      if (cloneResult.isLeft) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: cloneResult.left.errorMessage,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: RepositoryBlocStatus.cloneSuccess,
          cloneProgress: 1.0,
        ),
      );
    });
  }
}
