import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_hunk_widget.dart';

class DiffViewer extends StatelessWidget {
  final List<DiffHunkEntity> hunks;

  const DiffViewer({
    super.key,
    required this.hunks,
  });

  @override
  Widget build(BuildContext context) {
    if (hunks.isEmpty) {
      return const Center(child: Text('No changes'));
    }

    return ListView.builder(
      itemCount: hunks.length,
      itemBuilder: (_, i) {
        return DiffHunkWidget(hunk: hunks[i]);
      },
    );
  }
}
