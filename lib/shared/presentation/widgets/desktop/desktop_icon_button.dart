import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool selected;
  final Color? color;

  const DesktopIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.selected = false,
    this.color,
  });

  @override
  State<DesktopIconButton> createState() => DesktopIconButtonState();
}

class DesktopIconButtonState extends State<DesktopIconButton> {
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final theme = Theme.of(context);

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        opaque: false,
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onPressed : null,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.selected
                  ? theme.openGit.selected
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.selected
                    ? theme.openGit.selectedBorder
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: enabled
                  ? widget.color ?? theme.openGit.textSecondary
                  : theme.openGit.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
