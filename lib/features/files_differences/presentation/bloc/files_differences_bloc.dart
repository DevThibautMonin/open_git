import "dart:convert";

import "package:dart_mappable/dart_mappable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:injectable/injectable.dart";
import "package:open_git/features/files_differences/core/diff_mode_display_extensions.dart";
import "package:open_git/features/files_differences/domain/enums/file_content_display.dart";
import "package:open_git/features/files_differences/domain/enums/diff_mode_display.dart";
import "package:open_git/shared/core/constants/shared_preferences_keys.dart";
import "package:open_git/shared/core/extensions/git_service_failure_extension.dart";
import "package:open_git/shared/core/extensions/string_extensions.dart";
import "package:open_git/shared/core/services/git_diff_parser.dart";
import "package:open_git/shared/core/services/git_diff_service.dart";
import "package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart";
import "package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart";
import "package:open_git/shared/domain/entities/git_commit_entity.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/file_type_enum.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";

part "files_differences_event.dart";
part "files_differences_state.dart";
part "files_differences_bloc.mapper.dart";

@LazySingleton()
class FilesDifferencesBloc
    extends Bloc<FilesDifferencesEvent, FilesDifferencesState> {
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

    on<SetFileContentDisplay>((event, emit) {
      emit(state.copyWith(fileContentDisplay: event.display));
    });

    on<LoadDiffModeDisplay>((event, emit) {
      final raw = sharedPreferencesService.getString(
        SharedPreferencesKeys.diffModeDisplay,
      );

      final mode = DiffModeDisplayExtensions.fromRaw(raw);

      emit(state.copyWith(diffModeDisplay: mode));
    });

    on<LoadFileDiff>((event, emit) async {
      emit(
        state.copyWith(
          status: FilesDifferencesStatus.loading,
          selectedFile: event.file,
          selectedFilePath: event.file.path,
          diff: const [],
          originalContent: "",
          modifiedContent: "",
          imagePreviewBytes: null,
          sourceContent: null,
          previewErrorMessage: "",
          fileContentDisplay: FileContentDisplay.diff,
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
      final contentPairResult = await gitDiffService.getFileDiffContentPair(
        filePath: event.file.path,
        staged: event.file.staged,
        status: event.file.status,
      );

      final preview = await _loadPreview(event.file);

      emit(
        state.copyWith(
          diff: hunks,
          originalContent: contentPairResult.isRight
              ? contentPairResult.right.original
              : "",
          modifiedContent: contentPairResult.isRight
              ? contentPairResult.right.modified
              : "",
          status: FilesDifferencesStatus.loaded,
          imagePreviewBytes: preview.bytes,
          sourceContent: preview.source,
          previewErrorMessage: preview.errorMessage,
          fileContentDisplay: preview.bytes != null
              ? FileContentDisplay.preview
              : FileContentDisplay.diff,
        ),
      );
    });

    on<LoadCommitFileDiff>((event, emit) async {
      emit(
        state.copyWith(
          status: FilesDifferencesStatus.loading,
          selectedFilePath: event.filePath,
          diff: const [],
          originalContent: "",
          modifiedContent: "",
          imagePreviewBytes: null,
          sourceContent: null,
          previewErrorMessage: "",
          fileContentDisplay: FileContentDisplay.diff,
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
      final contentPairResult = await gitDiffService
          .getCommitFileDiffContentPair(
            commit: event.commit,
            filePath: event.filePath,
          );

      emit(
        state.copyWith(
          diff: hunks,
          originalContent: contentPairResult.isRight
              ? contentPairResult.right.original
              : "",
          modifiedContent: contentPairResult.isRight
              ? contentPairResult.right.modified
              : "",
          status: FilesDifferencesStatus.loaded,
        ),
      );
    });

    on<ClearFileDiff>((event, emit) {
      emit(
        state.copyWith(
          diff: const [],
          originalContent: "",
          modifiedContent: "",
          selectedFile: null,
          selectedFilePath: "",
          imagePreviewBytes: null,
          sourceContent: null,
          previewErrorMessage: "",
          fileContentDisplay: FileContentDisplay.diff,
        ),
      );
    });
  }

  Future<_FilePreviewData> _loadPreview(GitFileEntity file) async {
    if (file.path.fileType != FileTypeEnum.image ||
        file.status == GitFileStatus.deleted) {
      return const _FilePreviewData();
    }

    final bytesResult = await gitDiffService.getWorkingTreeFileBytes(
      filePath: file.path,
    );

    if (bytesResult.isLeft) {
      return _FilePreviewData(
        errorMessage: bytesResult.left.errorMessage,
      );
    }

    final bytes = bytesResult.right;
    final source = _isSvg(file.path)
        ? utf8.decode(bytes, allowMalformed: true)
        : null;

    return _FilePreviewData(
      bytes: bytes,
      source: source,
    );
  }

  bool _isSvg(String filePath) {
    return filePath.toLowerCase().endsWith(".svg");
  }
}

class _FilePreviewData {
  final List<int>? bytes;
  final String? source;
  final String errorMessage;

  const _FilePreviewData({
    this.bytes,
    this.source,
    this.errorMessage = "",
  });
}
