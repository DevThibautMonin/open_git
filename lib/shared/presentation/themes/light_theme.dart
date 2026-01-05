import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
);
