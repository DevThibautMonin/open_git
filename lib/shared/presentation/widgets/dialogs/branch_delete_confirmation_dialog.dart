import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text("Delete branch"),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            const TextSpan(text: "Are you sure you want to delete the branch "),
            TextSpan(
              text: branchName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: " ?\n\nThis action cannot be undone."),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
