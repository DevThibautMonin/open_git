import "package:flutter_test/flutter_test.dart";
import "package:open_git/shared/core/services/git_status_porcelain_parser.dart";
import "package:open_git/shared/domain/enums/git_file_status.dart";

void main() {
  late GitStatusPorcelainParser parser;

  setUp(() {
    parser = GitStatusPorcelainParser();
  });

  test("parses unstaged modified file", () {
    final files = parser.parse(" M lib/main.dart\n");

    expect(files, hasLength(1));
    expect(files.first.path, "lib/main.dart");
    expect(files.first.status, GitFileStatus.modified);
    expect(files.first.staged, false);
  });

  test("parses staged modified file", () {
    final files = parser.parse("M  lib/main.dart\n");

    expect(files, hasLength(1));
    expect(files.first.path, "lib/main.dart");
    expect(files.first.status, GitFileStatus.modified);
    expect(files.first.staged, true);
  });

  test("splits partially staged file into staged and unstaged entries", () {
    final files = parser.parse("MM lib/main.dart\n");

    expect(files, hasLength(2));
    expect(files[0].path, "lib/main.dart");
    expect(files[0].status, GitFileStatus.modified);
    expect(files[0].staged, true);
    expect(files[1].path, "lib/main.dart");
    expect(files[1].status, GitFileStatus.modified);
    expect(files[1].staged, false);
  });

  test("parses untracked file as unstaged", () {
    final files = parser.parse("?? test.dart\n");

    expect(files, hasLength(1));
    expect(files.first.path, "test.dart");
    expect(files.first.status, GitFileStatus.untracked);
    expect(files.first.staged, false);
  });

  test("keeps renamed target path for staged rename", () {
    final files = parser.parse("R  old.dart -> new.dart\n");

    expect(files, hasLength(1));
    expect(files.first.path, "new.dart");
    expect(files.first.status, GitFileStatus.renamed);
    expect(files.first.staged, true);
  });
}
