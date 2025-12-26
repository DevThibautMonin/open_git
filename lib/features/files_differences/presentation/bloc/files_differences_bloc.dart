import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/services/git_diff_parser.dart';
import 'package:open_git/shared/core/services/git_service.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

part 'files_differences_event.dart';
part 'files_differences_state.dart';
part 'files_differences_bloc.mapper.dart';

@LazySingleton()
class FilesDifferencesBloc extends Bloc<FilesDifferencesEvent, FilesDifferencesState> {
  final SharedPreferencesService sharedPreferencesService;
  final GitService gitService;

  FilesDifferencesBloc({
    required this.sharedPreferencesService,
    required this.gitService,
  }) : super(FilesDifferencesState()) {
    on<LoadFileDiff>((event, emit) async {
      emit(
        state.copyWith(
          status: FilesDifferencesStatus.loading,
          selectedFile: event.file,
        ),
      );

      try {
        final rawDiff = await gitService.getFileDiff(
          filePath: event.file.path,
          staged: event.file.staged,
          status: event.file.status,
        );

        final hunks = GitDiffParser.parse(rawDiff);

        emit(
          state.copyWith(
            diff: hunks,
            status: FilesDifferencesStatus.loaded,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: FilesDifferencesStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
