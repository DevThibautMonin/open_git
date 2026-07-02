import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool rightBorder;
  final bool leftBorder;
  final bool topBorder;
  final bool bottomBorder;
  final Color? color;

  const DesktopPanel({
    super.key,
    required this.child,
    this.padding,
    this.rightBorder = false,
    this.leftBorder = false,
    this.topBorder = false,
    this.bottomBorder = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.openGit.panel,
        border: Border(
          right: rightBorder
              ? BorderSide(color: theme.openGit.border)
              : BorderSide.none,
          left: leftBorder
              ? BorderSide(color: theme.openGit.border)
              : BorderSide.none,
          top: topBorder
              ? BorderSide(color: theme.openGit.border)
              : BorderSide.none,
          bottom: bottomBorder
              ? BorderSide(color: theme.openGit.border)
              : BorderSide.none,
        ),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}
