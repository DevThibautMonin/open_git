import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/code_block.dart';

class SshPermissionDeniedDialog extends StatelessWidget {
  const SshPermissionDeniedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("SSH authentication failed"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Your Git server refused the SSH connection because no valid SSH key is associated with your account.",
            ),
            SizedBox(height: 16),

            Text(
              "Follow these steps:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Text("1. Check if you already have an SSH key:"),
            CodeBlock("ls ~/.ssh"),

            SizedBox(height: 8),
            Text("2. If no key exists, generate one:"),
            CodeBlock('ssh-keygen -t ed25519 -C "your@email.com"'),

            SizedBox(height: 8),
            Text("3. Copy your public SSH key:"),
            CodeBlock("pbcopy < ~/.ssh/id_ed25519.pub"),

            SizedBox(height: 8),
            Text(
              "4. Add this key to your Git provider (GitHub, GitLab, Bitbucket, etc.) "
              "in the SSH keys settings of your account.",
            ),

            SizedBox(height: 8),
            Text("5. Verify the connection:"),
            CodeBlock("ssh -T git@your-git-host"),

            SizedBox(height: 12),
            Text(
              "Once completed, try pushing again.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Close"),
        ),
      ],
    );
  }
}
