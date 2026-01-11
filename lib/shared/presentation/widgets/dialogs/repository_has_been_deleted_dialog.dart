import "package:flutter/material.dart";

class RepositoryHasBeenDeletedDialog extends StatelessWidget {
  const RepositoryHasBeenDeletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Repository not found"),
      content: const Text(
        "The previously opened repository has been deleted or moved.\n\n"
        "Please open or clone a repository again.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            return Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
