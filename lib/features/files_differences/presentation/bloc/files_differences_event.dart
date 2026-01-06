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
  final GitCommitEntity commit;
  final String filePath;

  LoadCommitFileDiff({
    required this.commit,
    required this.filePath,
  });
}

class ClearFileDiff extends FilesDifferencesEvent {
  ClearFileDiff();
}
