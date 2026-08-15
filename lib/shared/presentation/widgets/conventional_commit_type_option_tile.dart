import "package:flutter/material.dart";
import "package:open_git/shared/domain/enums/conventional_commit_type.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class ConventionalCommitTypeOptionTile extends StatelessWidget {
  final ConventionalCommitType type;
  final VoidCallback onPressed;

  const ConventionalCommitTypeOptionTile({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: theme.openGit.panelAlt,
            border: Border.all(color: theme.openGit.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                child: Text(
                  type.value,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Menlo, Monaco, Courier New, monospace",
                  ),
                ),
              ),
              Gaps.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: theme.openGitBody.copyWith(
                        color: theme.openGit.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Gaps.h4,
                    Text(
                      type.description,
                      style: theme.openGitCaption.copyWith(
                        color: theme.openGit.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
