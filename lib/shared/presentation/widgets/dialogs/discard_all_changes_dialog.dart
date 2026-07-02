import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';

class DiscardAllChangesDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDiscard;

  const DiscardAllChangesDialog({
    super.key,
    required this.onCancel,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Discard all changes",
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
      child: const Text(
        "This will permanently discard all local changes. This action cannot be undone.",
      ),
    );
  }
}
