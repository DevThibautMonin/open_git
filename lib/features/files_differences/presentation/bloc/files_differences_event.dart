part of 'files_differences_bloc.dart';

sealed class FilesDifferencesEvent {}

class LoadFileDiff extends FilesDifferencesEvent {
  final GitFileEntity file;

  LoadFileDiff({required this.file});
}

class SetDiffModeDisplay extends FilesDifferencesEvent {
  final DiffModeDisplay mode;

  SetDiffModeDisplay(this.mode);
}

class LoadDiffModeDisplay extends FilesDifferencesEvent {
  LoadDiffModeDisplay();
}

class LoadCommitFileDiff extends FilesDifferencesEvent {
  final String commitSha;
  final String filePath;

  LoadCommitFileDiff({
    required this.commitSha,
    required this.filePath,
  });
}

class ClearFileDiff extends FilesDifferencesEvent {
  ClearFileDiff();
}
