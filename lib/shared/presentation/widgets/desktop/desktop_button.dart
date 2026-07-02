import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

enum DesktopButtonVariant {
  primary,
  subtle,
  danger,
}

class DesktopButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool selected;
  final DesktopButtonVariant variant;
  final String? tooltip;

  const DesktopButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.selected = false,
    this.variant = DesktopButtonVariant.subtle,
    this.tooltip,
  });

  @override
  State<DesktopButton> createState() => DesktopButtonState();
}

class DesktopButtonState extends State<DesktopButton> {
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final child = MouseRegion(
      opaque: false,
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? widget.onPressed : null,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor(context, enabled),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor(context, enabled)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor(context, enabled),
                  ),
                )
              else if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: 15,
                  color: foregroundColor(context, enabled),
                ),
              if (widget.icon != null || widget.isLoading)
                const SizedBox(width: 7),
              Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor(context, enabled),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip == null) return child;

    return Tooltip(
      message: widget.tooltip!,
      waitDuration: const Duration(milliseconds: 450),
      child: child,
    );
  }

  Color backgroundColor(BuildContext context, bool enabled) {
    final theme = Theme.of(context);

    if (!enabled) {
      return theme.openGit.panelAlt.withValues(alpha: 0.7);
    }

    if (widget.variant == DesktopButtonVariant.primary) {
      return theme.openGit.accent;
    }

    if (widget.variant == DesktopButtonVariant.danger) {
      return widget.selected
          ? theme.openGit.danger.withValues(alpha: 0.12)
          : Colors.transparent;
    }

    if (widget.selected) return theme.openGit.selected;

    return theme.openGit.panelAlt;
  }

  Color borderColor(BuildContext context, bool enabled) {
    final theme = Theme.of(context);

    if (!enabled) {
      return theme.openGit.border.withValues(alpha: 0.55);
    }

    if (widget.variant == DesktopButtonVariant.primary) {
      return theme.openGit.accent;
    }

    if (widget.variant == DesktopButtonVariant.danger) {
      return theme.openGit.danger;
    }

    if (widget.selected) return theme.openGit.selectedBorder;
    return theme.openGit.border;
  }

  Color foregroundColor(BuildContext context, bool enabled) {
    final theme = Theme.of(context);

    if (!enabled) return theme.openGit.textMuted;

    if (widget.variant == DesktopButtonVariant.primary) {
      return Colors.white;
    }

    if (widget.variant == DesktopButtonVariant.danger) {
      return theme.openGit.danger;
    }

    return theme.openGit.textPrimary;
  }
}
