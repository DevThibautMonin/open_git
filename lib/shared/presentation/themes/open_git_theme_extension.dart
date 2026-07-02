import 'package:flutter/material.dart';

@immutable
class OpenGitTheme extends ThemeExtension<OpenGitTheme> {
  final Color appBackground;
  final Color panel;
  final Color panelAlt;
  final Color toolbar;
  final Color border;
  final Color subtleBorder;
  final Color selected;
  final Color selectedBorder;
  final Color accent;
  final Color success;
  final Color danger;
  final Color warning;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color codeAdded;
  final Color codeRemoved;

  const OpenGitTheme({
    required this.appBackground,
    required this.panel,
    required this.panelAlt,
    required this.toolbar,
    required this.border,
    required this.subtleBorder,
    required this.selected,
    required this.selectedBorder,
    required this.accent,
    required this.success,
    required this.danger,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.codeAdded,
    required this.codeRemoved,
  });

  @override
  OpenGitTheme copyWith({
    Color? appBackground,
    Color? panel,
    Color? panelAlt,
    Color? toolbar,
    Color? border,
    Color? subtleBorder,
    Color? selected,
    Color? selectedBorder,
    Color? accent,
    Color? success,
    Color? danger,
    Color? warning,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? codeAdded,
    Color? codeRemoved,
  }) {
    return OpenGitTheme(
      appBackground: appBackground ?? this.appBackground,
      panel: panel ?? this.panel,
      panelAlt: panelAlt ?? this.panelAlt,
      toolbar: toolbar ?? this.toolbar,
      border: border ?? this.border,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      selected: selected ?? this.selected,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      codeAdded: codeAdded ?? this.codeAdded,
      codeRemoved: codeRemoved ?? this.codeRemoved,
    );
  }

  @override
  OpenGitTheme lerp(ThemeExtension<OpenGitTheme>? other, double t) {
    if (other is! OpenGitTheme) return this;

    return OpenGitTheme(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelAlt: Color.lerp(panelAlt, other.panelAlt, t)!,
      toolbar: Color.lerp(toolbar, other.toolbar, t)!,
      border: Color.lerp(border, other.border, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      selectedBorder: Color.lerp(selectedBorder, other.selectedBorder, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      codeAdded: Color.lerp(codeAdded, other.codeAdded, t)!,
      codeRemoved: Color.lerp(codeRemoved, other.codeRemoved, t)!,
    );
  }
}

extension OpenGitThemeDataX on ThemeData {
  OpenGitTheme get openGit => extension<OpenGitTheme>()!;

  TextStyle get openGitTitle {
    return textTheme.titleMedium?.copyWith(
          color: openGit.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ) ??
        TextStyle(
          color: openGit.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        );
  }

  TextStyle get openGitBody {
    return textTheme.bodyMedium?.copyWith(
          color: openGit.textPrimary,
          fontSize: 13,
          letterSpacing: 0,
        ) ??
        TextStyle(
          color: openGit.textPrimary,
          fontSize: 13,
        );
  }

  TextStyle get openGitCaption {
    return textTheme.bodySmall?.copyWith(
          color: openGit.textSecondary,
          fontSize: 11,
          letterSpacing: 0,
        ) ??
        TextStyle(
          color: openGit.textSecondary,
          fontSize: 11,
        );
  }

  TextStyle get openGitSectionLabel {
    return textTheme.labelMedium?.copyWith(
          color: openGit.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ) ??
        TextStyle(
          color: openGit.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        );
  }

  TextStyle get openGitMono {
    return TextStyle(
      color: openGit.textPrimary,
      fontFamily: 'monospace',
      fontSize: 12,
      height: 1.35,
      letterSpacing: 0,
    );
  }
}
