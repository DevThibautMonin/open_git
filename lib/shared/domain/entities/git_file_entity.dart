import 'package:dart_mappable/dart_mappable.dart';
import 'package:open_git/shared/domain/enums/git_file_status.dart';

part 'git_file_entity.mapper.dart';

@MappableClass()
class GitFileEntity with GitFileEntityMappable {
  final String path;
  final GitFileStatus status;
  final bool staged;

  GitFileEntity({
    required this.path,
    required this.status,
    this.staged = false,
  });
}
