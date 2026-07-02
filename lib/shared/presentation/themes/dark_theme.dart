import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.compact,
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF08111F),
    secondary: Color(0xFF5EEAD4),
    onSecondary: Color(0xFF08201C),
    error: Color(0xFFF87171),
    surface: Color(0xFF151820),
    onSurface: Color(0xFFE7EAF0),
  ),
  scaffoldBackgroundColor: const Color(0xFF0F1115),
  dividerColor: const Color(0xFF2A2F3A),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(fontSize: 14, letterSpacing: 0),
    bodyMedium: TextStyle(fontSize: 13, letterSpacing: 0),
    bodySmall: TextStyle(fontSize: 11, letterSpacing: 0),
    labelMedium: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFF1A1E27),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2A2F3A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2A2F3A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF60A5FA)),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF151820),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF151820),
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFF2A2F3A)),
    ),
    textStyle: const TextStyle(fontSize: 13, color: Color(0xFFE7EAF0)),
  ),
  extensions: const [
    OpenGitTheme(
      appBackground: Color(0xFF0F1115),
      panel: Color(0xFF151820),
      panelAlt: Color(0xFF1A1E27),
      toolbar: Color(0xFF12151C),
      border: Color(0xFF2A2F3A),
      subtleBorder: Color(0xB32A2F3A),
      selected: Color(0xFF18263F),
      selectedBorder: Color(0xFF3B82F6),
      accent: Color(0xFF60A5FA),
      success: Color(0xFF4ADE80),
      danger: Color(0xFFF87171),
      warning: Color(0xFFFBBF24),
      textPrimary: Color(0xFFE7EAF0),
      textSecondary: Color(0xFFA8AFBD),
      textMuted: Color(0xFF747D8C),
      codeAdded: Color(0xFF13271A),
      codeRemoved: Color(0xFF2A1719),
    ),
  ],
);
