import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_hunk_widget.dart';

class UnifiedDiffViewer extends StatelessWidget {
  const UnifiedDiffViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, state) {
        if (state.diff.isEmpty) {
          return const Center(child: Text('No changes'));
        }
        return ListView.builder(
          itemCount: state.diff.length,
          itemBuilder: (_, i) {
            return UnifiedDiffHunkWidget(hunk: state.diff[i]);
          },
        );
      },
    );
  }
}
