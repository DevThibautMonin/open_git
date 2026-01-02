import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_hunk_widget.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';

class SplitDiffViewer extends StatelessWidget {
  final GitFileEntity? file;

  const SplitDiffViewer({
    super.key,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, state) {
        if (state.diff.isEmpty) {
          return const Center(child: Text('No changes'));
        }
        return Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: state.diff.length,
                itemBuilder: (_, i) {
                  return SplitDiffHunkWidget(hunk: state.diff[i]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
