import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopSectionHeader extends StatelessWidget {
  final String title;
  final String? count;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const DesktopSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: theme.openGitSectionLabel,
            ),
          ),
          if (count != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.openGit.panelAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.openGit.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: Text(
                  count!,
                  style: theme.openGitCaption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
