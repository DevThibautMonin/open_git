import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String tooltip;

  const DesktopCheckbox({
    super.key,
    required this.value,
    required this.tooltip,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        opaque: false,
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged!(!value) : null,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: value
                      ? theme.openGit.accent
                      : theme.openGit.panelAlt,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: value
                        ? theme.openGit.accent
                        : theme.openGit.border,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
