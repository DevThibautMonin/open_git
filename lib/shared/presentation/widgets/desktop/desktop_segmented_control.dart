import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class DesktopSegment<T> {
  final T value;
  final IconData icon;
  final String label;

  const DesktopSegment({
    required this.value,
    required this.icon,
    required this.label,
  });
}

class DesktopSegmentedControl<T> extends StatelessWidget {
  final List<DesktopSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const DesktopSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.openGit.panelAlt,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: theme.openGit.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: segments.map((segment) {
            final isSelected = segment.value == selected;

            return Tooltip(
              message: segment.label,
              waitDuration: const Duration(milliseconds: 450),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(segment.value),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.openGit.panel
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected
                          ? theme.openGit.selectedBorder
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        segment.icon,
                        size: 14,
                        color: isSelected
                            ? theme.openGit.accent
                            : theme.openGit.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        segment.label,
                        style: TextStyle(
                          color: isSelected
                              ? theme.openGit.textPrimary
                              : theme.openGit.textSecondary,
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
          }).toList(),
        ),
      ),
    );
  }
}
