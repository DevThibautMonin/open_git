import 'package:flutter/material.dart';

enum DiffLineType {
  added(value: "+", color: Colors.green),
  removed(value: "-", color: Colors.red),
  unchanged(value: "", color: Colors.transparent)
  ;

  final String value;
  final Color color;

  const DiffLineType({
    required this.value,
    required this.color,
  });

  Color get backgroundColor {
    switch (this) {
      case DiffLineType.added:
      case DiffLineType.removed:
        return color.withValues(alpha: 0.2);
      case DiffLineType.unchanged:
        return Colors.transparent;
    }
  }
}
