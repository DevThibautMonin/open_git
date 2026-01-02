import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
  ),
  textTheme: TextTheme(
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
);
