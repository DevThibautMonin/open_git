import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';

class DiffLineEntity {
  final DiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  const DiffLineEntity({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });
}
