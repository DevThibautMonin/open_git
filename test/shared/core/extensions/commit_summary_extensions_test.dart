import "package:flutter_test/flutter_test.dart";
import "package:open_git/shared/core/extensions/commit_summary_extensions.dart";
import "package:open_git/shared/domain/enums/conventional_commit_type.dart";

void main() {
  test("adds a conventional commit type to an empty summary", () {
    expect(
      "".withConventionalCommitType(ConventionalCommitType.feat),
      "feat: ",
    );
  });

  test("prefixes an existing summary", () {
    expect(
      "add repository picker".withConventionalCommitType(
        ConventionalCommitType.feat,
      ),
      "feat: add repository picker",
    );
  });

  test("replaces an existing conventional commit type", () {
    expect(
      "fix: add repository picker".withConventionalCommitType(
        ConventionalCommitType.refactor,
      ),
      "refactor: add repository picker",
    );
  });

  test("replaces an existing scoped conventional commit type", () {
    expect(
      "fix(repository)!: add picker".withConventionalCommitType(
        ConventionalCommitType.feat,
      ),
      "feat: add picker",
    );
  });
}
