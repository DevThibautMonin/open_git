import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopListRow extends StatefulWidget {
  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? height;

  const DesktopListRow({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.margin = const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    this.height,
  });

  @override
  State<DesktopListRow> createState() => DesktopListRowState();
}

class DesktopListRowState extends State<DesktopListRow> {
  @override
  Widget build(BuildContext context) {
    final enabled =
        widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onSecondaryTapDown != null;
    final theme = Theme.of(context);

    return MouseRegion(
      opaque: false,
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTapDown: widget.onSecondaryTapDown,
        child: Container(
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.openGit.selected
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.selected
                    ? theme.openGit.selectedBorder
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
