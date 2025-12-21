import 'package:open_git/shared/domain/enums/git_file_status.dart';

class GitFileEntity {
  final String path;
  final GitFileStatus status;
  final bool staged;
  final bool selected;

  GitFileEntity({
    required this.path,
    required this.status,
    this.staged = false,
    this.selected = false,
  });
}
