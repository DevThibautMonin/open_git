import "package:flutter/material.dart";
import "package:open_git/shared/domain/enums/conventional_commit_type.dart";
import "package:open_git/shared/presentation/widgets/conventional_commit_type_dialog.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class ConventionalCommitTypePicker extends StatelessWidget {
  final ValueChanged<ConventionalCommitType> onSelected;

  const ConventionalCommitTypePicker({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: "Choose commit type",
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final selected = await showDialog<ConventionalCommitType>(
              context: context,
              builder: (context) {
                return const ConventionalCommitTypeDialog();
              },
            );

            if (selected == null) return;

            onSelected(selected);
          },
          child: SizedBox(
            width: 36,
            height: 48,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.openGit.panelAlt,
                  border: Border.all(color: theme.openGit.border),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "?",
                    style: theme.openGitBody.copyWith(
                      color: theme.openGit.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
