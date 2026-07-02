import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_checkbox.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart';
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
        final isSelected = state.selectedFile?.path == file.path;
        final theme = Theme.of(context);

        return DesktopListRow(
          selected: isSelected,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          onSecondaryTapDown: (details) async {
            context.read<FilesDifferencesBloc>().add(LoadFileDiff(file: file));
            context.read<WorkingDirectoryBloc>().add(SelectFile(file: file));
            await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                details.globalPosition.dx,
                details.globalPosition.dy,
                details.globalPosition.dx,
                details.globalPosition.dy,
              ),
              items: [
                PopupMenuItem(
                  onTap: () {
                    context.read<WorkingDirectoryBloc>().add(
                      UpdateWorkingDirectoryStatus(
                        status:
                            WorkingDirectoryBlocStatus.askForDiscardFileChanges,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.remove_circle_outline, size: 16),
                      Gaps.w8,
                      Text("Discard changes"),
                    ],
                  ),
                ),
              ],
            );
          },
          onTap: () {
            context.read<FilesDifferencesBloc>().add(LoadFileDiff(file: file));

            context.read<WorkingDirectoryBloc>().add(SelectFile(file: file));
          },
          child: Row(
            children: [
              Icon(
                file.status.icon,
                size: 16,
                color: file.status.color,
              ),
              Gaps.w4,
              DesktopCheckbox(
                value: file.staged,
                tooltip: file.staged ? 'Unstage file' : 'Stage file',
                onChanged: (_) {
                  context.read<WorkingDirectoryBloc>().add(
                    ToggleFileStaging(
                      file: file,
                      stage: !file.staged,
                    ),
                  );
                },
              ),
              FileTypeIcon(type: file.path.fileType),
              Gaps.w8,
              Expanded(
                child: Text(
                  file.path,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
