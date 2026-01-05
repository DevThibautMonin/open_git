import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.dark,
  ),
  textTheme: const TextTheme(
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
);
