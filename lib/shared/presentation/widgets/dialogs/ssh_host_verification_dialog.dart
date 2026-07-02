import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class SshHostVerificationDialog extends StatelessWidget {
  const SshHostVerificationDialog({super.key});

  static const _command = "ssh -T git@github.com";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopDialog(
      title: "SSH host verification required",
      icon: Icons.verified_user_outlined,
      width: 540,
      actions: [
        DesktopButton(
          label: "Copy command",
          icon: Icons.copy,
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
        ),
        DesktopButton(
          label: "I ran the command",
          icon: Icons.check,
          variant: DesktopButtonVariant.primary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Column(
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
              color: theme.openGit.panelAlt,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.openGit.border),
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
    );
  }
}
