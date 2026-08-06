import "package:injectable/injectable.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";

@LazySingleton()
class GitStatusPorcelainParser {
  List<GitFileEntity> parse(String output) {
    final files = <GitFileEntity>[];

    for (final line in output.split("\n")) {
      if (line.trim().isEmpty) continue;
      if (line.length < 4) continue;

      final indexStatus = line[0];
      final workingTreeStatus = line[1];
      final path = _parsePath(line);

      if (indexStatus == "?" && workingTreeStatus == "?") {
        files.add(
          GitFileEntity(
            path: path,
            status: GitFileStatus.untracked,
          ),
        );
        continue;
      }

      if (indexStatus != " ") {
        files.add(
          GitFileEntity(
            path: path,
            status: _mapGitFileStatus(indexStatus),
            staged: true,
          ),
        );
      }

      if (workingTreeStatus != " ") {
        files.add(
          GitFileEntity(
            path: path,
            status: _mapGitFileStatus(workingTreeStatus),
          ),
        );
      }
    }

    return files;
  }

  String _parsePath(String line) {
    var path = line.substring(3).trim();

    if (path.startsWith('"') && path.endsWith('"')) {
      path = path.substring(1, path.length - 1);
    }

    var finalPath = path.contains("->") ? path.split("->").last.trim() : path;

    if (finalPath.startsWith('"') && finalPath.endsWith('"')) {
      finalPath = finalPath.substring(1, finalPath.length - 1);
    }

    return finalPath;
  }

  GitFileStatus _mapGitFileStatus(String value) {
    return switch (value) {
      "?" => GitFileStatus.untracked,
      "A" => GitFileStatus.added,
      "D" => GitFileStatus.deleted,
      "R" => GitFileStatus.renamed,
      _ => GitFileStatus.modified,
    };
  }
}
