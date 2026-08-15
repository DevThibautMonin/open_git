import "package:flutter/material.dart";
import "package:open_git/shared/domain/enums/conventional_commit_type.dart";
import "package:open_git/shared/presentation/widgets/conventional_commit_type_option_tile.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart";

class ConventionalCommitTypeDialog extends StatelessWidget {
  const ConventionalCommitTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Choose a commit type",
      icon: Icons.help_outline,
      width: 640,
      actions: [
        DesktopButton(
          label: "Close",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            children: ConventionalCommitType.values
                .map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ConventionalCommitTypeOptionTile(
                      type: type,
                      onPressed: () {
                        Navigator.pop(context, type);
                      },
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}
