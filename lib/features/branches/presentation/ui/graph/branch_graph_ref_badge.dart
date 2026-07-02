import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class BranchGraphRefBadge extends StatelessWidget {
  final String refName;

  const BranchGraphRefBadge({
    super.key,
    required this.refName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor = theme.openGit.panelAlt;
    Color textColor = theme.openGit.textSecondary;

    String cleanRef = refName;
    if (refName.startsWith('HEAD -> ')) {
      bgColor = theme.openGit.accent;
      textColor = Colors.white;
      cleanRef = refName.replaceFirst('HEAD -> ', '');
    } else if (refName.contains('/')) {
      bgColor = theme.openGit.success.withValues(alpha: 0.12);
      textColor = theme.openGit.success;
    } else if (refName.startsWith('tag: ')) {
      bgColor = theme.openGit.warning.withValues(alpha: 0.16);
      textColor = theme.openGit.warning;
      cleanRef = refName.replaceFirst('tag: ', '');
    }

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        cleanRef,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
