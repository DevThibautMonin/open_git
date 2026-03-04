import 'package:flutter/material.dart';

class BranchGraphRefBadge extends StatelessWidget {
  final String refName;

  const BranchGraphRefBadge({
    super.key,
    required this.refName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Simple heuristic to differentiate HEAD, remote branches, local branches, and tags
    Color bgColor = theme.colorScheme.surfaceContainerHighest;
    Color textColor = theme.colorScheme.onSurfaceVariant;
    
    String cleanRef = refName;
    if (refName.startsWith('HEAD -> ')) {
      bgColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      cleanRef = refName.replaceFirst('HEAD -> ', '');
    } else if (refName.contains('/')) {
      // Remote branch
      bgColor = theme.colorScheme.tertiaryContainer;
      textColor = theme.colorScheme.onTertiaryContainer;
    } else if (refName.startsWith('tag: ')) {
      bgColor = Colors.amber.withValues(alpha: 0.2);
      textColor = Colors.amber.shade900;
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
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
