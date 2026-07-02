import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';

class BranchDeleteConfirmationDialog extends StatelessWidget {
  final String branchName;
  final VoidCallback onDelete;

  const BranchDeleteConfirmationDialog({
    super.key,
    required this.branchName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Delete branch",
      icon: Icons.delete_outline,
      actions: [
        DesktopButton(
          label: "Cancel",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        DesktopButton(
          label: "Delete",
          icon: Icons.delete_outline,
          variant: DesktopButtonVariant.danger,
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            const TextSpan(text: "Are you sure you want to delete the branch "),
            TextSpan(
              text: branchName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: "?\n\nThis action cannot be undone."),
          ],
        ),
      ),
    );
  }
}
