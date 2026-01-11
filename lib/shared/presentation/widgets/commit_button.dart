import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      child: Text(text),
    );
  }
}
