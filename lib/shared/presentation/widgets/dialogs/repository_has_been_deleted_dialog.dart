import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart";

class RepositoryHasBeenDeletedDialog extends StatelessWidget {
  const RepositoryHasBeenDeletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Repository not found",
      icon: Icons.folder_off_outlined,
      actions: [
        DesktopButton(
          label: "OK",
          onPressed: () {
            return Navigator.pop(context);
          },
        ),
      ],
      child: const Text(
        "The previously opened repository has been deleted or moved.\n\n"
        "Please open or clone a repository again.",
      ),
    );
  }
}
