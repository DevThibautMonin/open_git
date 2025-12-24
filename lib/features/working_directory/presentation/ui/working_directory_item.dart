import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class WorkingDirectoryItem extends StatelessWidget {
  final GitFileEntity file;
  final Function(GitFileEntity file) onSelected;

  const WorkingDirectoryItem({
    super.key,
    required this.file,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(file);
      },
      child: Row(
        children: [
          Gaps.w8,
          Icon(
            file.status.icon,
            size: 16,
            color: file.status.color,
          ),
          Checkbox(
            value: file.staged,
            onChanged: (_) {
              context.read<WorkingDirectoryBloc>().add(
                ToggleFileStaging(file: file, stage: !file.staged),
              );
            },
          ),
          FileTypeIcon(
            type: file.path.fileType,
          ),
          Gaps.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
