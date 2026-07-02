import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/code_block.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';

class GitHttpsRemoteDialog extends StatelessWidget {
  final String sshCommand;

  const GitHttpsRemoteDialog({
    super.key,
    required this.sshCommand,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "SSH required",
      icon: Icons.key,
      actions: [
        DesktopButton(
          label: "Close",
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
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
          Text(
            "This command updates your Git remote to use SSH.",
            style: TextStyle(
              color: Theme.of(context).openGit.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
