enum ConventionalCommitType {
  feat(
    value: "feat",
    label: "Feature",
    description:
        "Use when the commit adds a new user-facing capability or behavior.",
  ),
  fix(
    value: "fix",
    label: "Fix",
    description:
        "Use when the commit fixes a bug, broken flow, or incorrect behavior.",
  ),
  refactor(
    value: "refactor",
    label: "Refactor",
    description:
        "Use when the code changes internally without changing what users can do.",
  ),
  docs(
    value: "docs",
    label: "Docs",
    description:
        "Use when the commit only changes documentation, guides, or comments.",
  ),
  test(
    value: "test",
    label: "Test",
    description:
        "Use when the commit adds, updates, or repairs automated tests.",
  ),
  chore(
    value: "chore",
    label: "Chore",
    description:
        "Use for maintenance work that does not fit another type, such as cleanup.",
  ),
  style(
    value: "style",
    label: "Style",
    description:
        "Use for formatting, whitespace, or style-only changes with no logic change.",
  ),
  perf(
    value: "perf",
    label: "Performance",
    description:
        "Use when the commit makes an existing path faster or less resource-heavy.",
  ),
  ci(
    value: "ci",
    label: "CI",
    description:
        "Use for CI workflows, release automation, checks, or deployment scripts.",
  ),
  build(
    value: "build",
    label: "Build",
    description:
        "Use for dependency, compiler, packaging, or build system changes.",
  );

  final String value;
  final String label;
  final String description;

  const ConventionalCommitType({
    required this.value,
    required this.label,
    required this.description,
  });
}
