import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';

class DiffHunkEntity {
  final int oldStart;
  final int newStart;
  final List<DiffLineEntity> lines;

  const DiffHunkEntity({
    required this.oldStart,
    required this.newStart,
    required this.lines,
  });
}
