import "package:open_git/shared/domain/entities/git_file_entity.dart";

extension GitFileEntityExtensions on GitFileEntity {
  bool representsSameChangeAs(GitFileEntity other) {
    return path == other.path && staged == other.staged;
  }
}
