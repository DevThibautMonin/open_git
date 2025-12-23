import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/code_block.dart';

class GitHttpsRemoteDialog extends StatelessWidget {
  final String sshCommand;

  const GitHttpsRemoteDialog({
    super.key,
    required this.sshCommand,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("SSH required"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This repository uses HTTPS authentication.\n\n"
            "OpenGit only supports SSH to push commits.\n\n"
            "To continue, you must convert the remote URL to SSH.",
          ),
          const SizedBox(height: 12),
          const Text("Run this command in your terminal:"),
          const SizedBox(height: 8),
          CodeBlock(sshCommand),
          const SizedBox(height: 8),
          const Text(
            "This command updates your Git remote to use SSH.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
