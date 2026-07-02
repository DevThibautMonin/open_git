import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';

class DiscardFileChangesDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDiscard;
  final GitFileEntity? file;

  const DiscardFileChangesDialog({
    super.key,
    required this.onCancel,
    required this.onDiscard,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Discard file changes",
      icon: Icons.remove_circle_outline,
      actions: [
        DesktopButton(
          label: "Cancel",
          onPressed: () {
            onCancel();
          },
        ),
        DesktopButton(
          label: "Discard",
          icon: Icons.remove_circle_outline,
          variant: DesktopButtonVariant.danger,
          onPressed: () {
            onDiscard();
          },
        ),
      ],
      child: Text(
        "This will permanently discard ${file?.path} changes. This action cannot be undone.",
      ),
    );
  }
}
