import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/services/git_remote_service.dart';
import 'package:open_git/shared/core/services/git_repository_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

part 'repository_event.dart';
part 'repository_state.dart';
part 'repository_bloc.mapper.dart';

@LazySingleton()
class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final GitRepositoryService gitRepositoryService;
  final GitRemoteService gitRemoteService;
  final SharedPreferencesService sharedPreferencesService;

  RepositoryBloc({
    required this.gitRepositoryService,
    required this.gitRemoteService,
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
      await gitRepositoryService.selectRepository();

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

      final existsResult = await gitRepositoryService.repositoryExists();

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
      emit(state.copyWith(status: RepositoryBlocStatus.fetching));

      final result = await gitRemoteService.fetch();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: RepositoryBlocStatus.error,
              errorMessage: failure.errorMessage,
            ),
          );
        },
        (_) {
          emit(state.copyWith(status: RepositoryBlocStatus.fetched));
        },
      );
    });

    on<CloneRepositoryConfirmed>((event, emit) async {
      emit(
        state.copyWith(
          status: RepositoryBlocStatus.cloning,
          cloneProgress: 0,
        ),
      );

      final dirResult = await gitRepositoryService.ensureDirectoryIsEmpty(event.destinationPath);

      if (dirResult.isLeft) {
        emit(
          state.copyWith(
            status: RepositoryBlocStatus.error,
            errorMessage: dirResult.left.errorMessage,
          ),
        );
        return;
      }

      final cloneResult = await gitRepositoryService.cloneRepositoryWithProgress(
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
