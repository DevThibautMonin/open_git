import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const DesktopEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.openGit.textMuted,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.openGitTitle,
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.openGitCaption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
