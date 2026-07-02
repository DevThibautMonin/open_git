import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  visualDensity: VisualDensity.compact,
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: Color(0xFF0F766E),
    onSecondary: Colors.white,
    error: Color(0xFFDC2626),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF171A21),
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F5F7),
  dividerColor: const Color(0xFFDDE2EA),
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
    fillColor: const Color(0xFFF8F9FB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFDDE2EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFDDE2EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2563EB)),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFDDE2EA)),
    ),
    textStyle: const TextStyle(fontSize: 13, color: Color(0xFF171A21)),
  ),
  extensions: const [
    OpenGitTheme(
      appBackground: Color(0xFFF4F5F7),
      panel: Color(0xFFFFFFFF),
      panelAlt: Color(0xFFF8F9FB),
      toolbar: Color(0xFFFBFCFD),
      border: Color(0xFFDDE2EA),
      subtleBorder: Color(0xCCDDE2EA),
      selected: Color(0xFFEAF2FF),
      selectedBorder: Color(0xFF2563EB),
      accent: Color(0xFF2563EB),
      success: Color(0xFF15803D),
      danger: Color(0xFFDC2626),
      warning: Color(0xFFD97706),
      textPrimary: Color(0xFF171A21),
      textSecondary: Color(0xFF5B6472),
      textMuted: Color(0xFF8A94A5),
      codeAdded: Color(0xFFEAF8EF),
      codeRemoved: Color(0xFFFFEBEE),
    ),
  ],
);
