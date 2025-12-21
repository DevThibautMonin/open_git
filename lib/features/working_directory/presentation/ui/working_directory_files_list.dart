import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_item.dart';

class WorkingDirectoryFilesList extends StatelessWidget {
  final List<GitFileEntity> files;
  final ValueChanged<GitFileEntity> onCheckboxToggled;
  final Function(GitFileEntity file) onFileSelected;

  const WorkingDirectoryFilesList({
    super.key,
    required this.files,
    required this.onCheckboxToggled,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(
        child: Text("No local changes"),
      );
    }

    return Column(
      children: [
        Text("Working directory"),
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return WorkingDirectoryItem(
                file: file,
                onCheckboxToggled: (_) {
                  onCheckboxToggled(file);
                },
                onSelected: (file) {
                  onFileSelected(file);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
