import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/features/files_differences/core/diff_mode_display_extensions.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/core/extensions/git_service_failure_extension.dart';
import 'package:open_git/shared/core/services/git_diff_parser.dart';
import 'package:open_git/shared/core/services/git_diff_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/shared/domain/entities/git_commit_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

part 'files_differences_event.dart';
part 'files_differences_state.dart';
part 'files_differences_bloc.mapper.dart';

@LazySingleton()
class FilesDifferencesBloc extends Bloc<FilesDifferencesEvent, FilesDifferencesState> {
  final SharedPreferencesService sharedPreferencesService;
  final GitDiffService gitDiffService;

  FilesDifferencesBloc({
    required this.sharedPreferencesService,
    required this.gitDiffService,
  }) : super(FilesDifferencesState()) {
    on<SetDiffModeDisplay>((event, emit) async {
      await sharedPreferencesService.setString(
        SharedPreferencesKeys.diffModeDisplay,
        event.mode.raw,
      );

      emit(state.copyWith(diffModeDisplay: event.mode));
    });

    on<LoadDiffModeDisplay>((event, emit) {
      final raw = sharedPreferencesService.getString(SharedPreferencesKeys.diffModeDisplay);

      final mode = DiffModeDisplayExtensions.fromRaw(raw);

      emit(state.copyWith(diffModeDisplay: mode));
    });

    on<LoadFileDiff>((event, emit) async {
      emit(
        state.copyWith(
          status: FilesDifferencesStatus.loading,
          selectedFile: event.file,
        ),
      );

      final diffResult = await gitDiffService.getFileDiff(
        filePath: event.file.path,
        staged: event.file.staged,
        status: event.file.status,
      );

      if (diffResult.isLeft) {
        emit(
          state.copyWith(
            status: FilesDifferencesStatus.error,
            errorMessage: diffResult.left.errorMessage,
          ),
        );
        return;
      }

      final hunks = GitDiffParser.parse(diffResult.right);

      emit(
        state.copyWith(
          diff: hunks,
          status: FilesDifferencesStatus.loaded,
        ),
      );
    });

    on<LoadCommitFileDiff>((event, emit) async {
      emit(
        state.copyWith(
          status: FilesDifferencesStatus.loading,
        ),
      );

      final diffResult = await gitDiffService.getCommitFileDiff(
        commit: event.commit,
        filePath: event.filePath,
      );

      if (diffResult.isLeft) {
        emit(
          state.copyWith(
            status: FilesDifferencesStatus.error,
            errorMessage: diffResult.left.errorMessage,
          ),
        );
        return;
      }

      final hunks = GitDiffParser.parse(diffResult.right);

      emit(
        state.copyWith(
          diff: hunks,
          status: FilesDifferencesStatus.loaded,
        ),
      );
    });

    on<ClearFileDiff>((event, emit) {
      emit(
        state.copyWith(
          diff: null,
          selectedFile: null,
        ),
      );
    });
  }
}
