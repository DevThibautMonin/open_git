part of 'files_differences_bloc.dart';

sealed class FilesDifferencesEvent {}

class LoadFileDiff extends FilesDifferencesEvent {
  final GitFileEntity file;

  LoadFileDiff({required this.file});
}
