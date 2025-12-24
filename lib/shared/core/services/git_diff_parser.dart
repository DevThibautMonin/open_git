import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_line_entity.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';
import 'package:open_git/shared/core/constants/git_regex.dart';

class GitDiffParser {
  static List<DiffHunkEntity> parse(String diff) {
    final hunks = <DiffHunkEntity>[];
    final lines = diff.split('\n');

    DiffHunkEntity? currentHunk;
    int oldLine = 0;
    int newLine = 0;

    for (final line in lines) {
      if (line.startsWith('@@')) {
        final match = GitRegex.diff.firstMatch(line);
        if (match != null) {
          oldLine = int.parse(match.group(1)!);
          newLine = int.parse(match.group(2)!);
          currentHunk = DiffHunkEntity(
            oldStart: oldLine,
            newStart: newLine,
            lines: [],
          );
          hunks.add(currentHunk);
        }
        continue;
      }

      if (currentHunk == null) continue;

      if (line.startsWith('+')) {
        currentHunk.lines.add(
          DiffLineEntity(
            type: DiffLineType.added,
            content: line.substring(1),
            newLineNumber: newLine++,
          ),
        );
      } else if (line.startsWith('-')) {
        currentHunk.lines.add(
          DiffLineEntity(
            type: DiffLineType.removed,
            content: line.substring(1),
            oldLineNumber: oldLine++,
          ),
        );
      } else {
        currentHunk.lines.add(
          DiffLineEntity(
            type: DiffLineType.unchanged,
            content: line.startsWith(' ') ? line.substring(1) : line,
            oldLineNumber: oldLine++,
            newLineNumber: newLine++,
          ),
        );
      }
    }

    return hunks;
  }
}
