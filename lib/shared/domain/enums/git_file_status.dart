import 'package:flutter/material.dart';

enum GitFileStatus {
  modified(icon: Icons.edit),
  added(icon: Icons.add),
  deleted(icon: Icons.remove),
  renamed(icon: Icons.drive_file_rename_outline),
  untracked(icon: Icons.help_outline)
  ;

  final IconData icon;

  const GitFileStatus({
    required this.icon,
  });

  Color get color {
    switch (this) {
      case GitFileStatus.added:
        return Colors.green.shade400;
      case GitFileStatus.deleted:
        return Colors.red.shade400;
      case GitFileStatus.renamed:
        return Colors.orange.shade400;
      case GitFileStatus.untracked:
        return Colors.grey.shade400;
      case GitFileStatus.modified:
        return Colors.blue.shade400;
    }
  }
}
