import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class WorkingDirectoryItem extends StatelessWidget {
  final GitFileEntity file;

  const WorkingDirectoryItem({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        final isSelected = state.selectedFilePath == file.path;
        return InkWell(
          onTap: () {
            context.read<FilesDifferencesBloc>().add(LoadFileDiff(file: file));

            context.read<WorkingDirectoryBloc>().add(SelectFile(file: file));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: isSelected
                ? BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  )
                : null,
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
                FileTypeIcon(type: file.path.fileType),
                Gaps.w8,
                Expanded(
                  child: Text(
                    file.path,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
