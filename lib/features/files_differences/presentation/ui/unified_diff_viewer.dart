import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_hunk_widget.dart';

class UnifiedDiffViewer extends StatelessWidget {
  final List<DiffHunkEntity> hunks;

  const UnifiedDiffViewer({
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
        return UnifiedDiffHunkWidget(hunk: hunks[i]);
      },
    );
  }
}
