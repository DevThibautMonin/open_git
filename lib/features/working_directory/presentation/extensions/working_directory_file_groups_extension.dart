import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";

extension WorkingDirectoryFileGroupsExtension on WorkingDirectoryState {
  List<GitFileEntity> get stagedFiles {
    return files.where((file) => file.staged).toList(growable: false);
  }

  List<GitFileEntity> get unstagedFiles {
    return files.where((file) => !file.staged).toList(growable: false);
  }
}
