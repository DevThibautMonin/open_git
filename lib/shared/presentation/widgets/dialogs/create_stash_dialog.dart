import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class CreateStashDialog extends StatefulWidget {
  final ValueChanged<String> onCreate;

  const CreateStashDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateStashDialog> createState() => CreateStashDialogState();
}

class CreateStashDialogState extends State<CreateStashDialog> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: "Stash changes",
      icon: Icons.archive_outlined,
      width: 460,
      actions: [
        DesktopButton(
          label: "Cancel",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        DesktopButton(
          icon: Icons.archive_outlined,
          label: "Stash",
          variant: DesktopButtonVariant.primary,
          onPressed: () {
            widget.onCreate(messageController.text.trim());
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DesktopTextField(
            controller: messageController,
            labelText: "Message",
            hintText: "Optional stash message",
            onSubmitted: (value) {
              widget.onCreate(value.trim());
              Navigator.of(context).pop();
            },
          ),
          Gaps.h8,
        ],
      ),
    );
  }
}
