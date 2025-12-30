import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text("Discard all changes"),
      content: const Text(
        "This will permanently discard all local changes. This action cannot be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            onDiscard();
          },
          child: const Text("Discard"),
        ),
      ],
    );
  }
}
