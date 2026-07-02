import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';

class CommitButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isEnabled;

  const CommitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopButton(
      icon: Icons.check,
      label: text,
      variant: DesktopButtonVariant.primary,
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
