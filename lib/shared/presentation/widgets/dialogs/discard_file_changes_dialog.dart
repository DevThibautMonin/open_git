import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

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
    return AlertDialog(
      title: const Text("Discard file changes"),
      content: Text(
        "This will permanently discard ${file?.path} changes. This action cannot be undone.",
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
