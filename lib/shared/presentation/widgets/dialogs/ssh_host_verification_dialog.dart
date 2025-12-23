import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class SshHostVerificationDialog extends StatelessWidget {
  const SshHostVerificationDialog({super.key});

  static const _command = "ssh -T git@github.com";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("SSH host verification required"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "GitHub is not yet trusted by your system.\n\n"
            "This usually happens when GitHub was removed from your known SSH hosts.\n"
            "To continue, you must manually verify GitHub's SSH host in your terminal.",
          ),
          Gaps.h16,

          const Text(
            "Run this command in your terminal :",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Gaps.h8,

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              _command,
              style: const TextStyle(
                fontFamily: "monospace",
                fontSize: 13,
              ),
            ),
          ),

          Gaps.h12,

          const Text(
            "When prompted, type 'yes' and press Enter.\n"
            "Once done, come back here and try pushing again.",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: _command));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Command copied to clipboard"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text("Copy command"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("I ran the command"),
        ),
      ],
    );
  }
}
