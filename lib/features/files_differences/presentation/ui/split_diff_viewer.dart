import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_hunk_widget.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

class SplitDiffViewer extends StatelessWidget {
  final List<DiffHunkEntity> hunks;
  final GitFileEntity? file;

  const SplitDiffViewer({
    super.key,
    required this.hunks,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    if (hunks.isEmpty) {
      return const Center(child: Text('No changes'));
    }

    return Column(
      children: [
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: hunks.length,
            itemBuilder: (_, i) {
              return SplitDiffHunkWidget(hunk: hunks[i]);
            },
          ),
        ),
      ],
    );
  }
}
