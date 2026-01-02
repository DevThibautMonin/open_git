import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_item.dart';
import 'package:open_git/shared/presentation/widgets/commit_message_textfield.dart';

class WorkingDirectoryFilesList extends StatelessWidget {
  const WorkingDirectoryFilesList({
    super.key,
  });

  bool _areAllFilesStaged(List<GitFileEntity> files) {
    if (files.isEmpty) return false;
    return files.every((f) => f.staged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        if (state.files.isEmpty) {
          return const Center(
            child: Text("No local changes"),
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _areAllFilesStaged(state.files),
                  onChanged: (checked) {
                    context.read<WorkingDirectoryBloc>().add(ToggleAllFilesStaging(stage: checked ?? false));
                  },
                ),
                Text("(${state.files.length}) Changed files"),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ActionChip(
                    avatar: const Icon(
                      Icons.remove,
                      size: 18,
                    ),
                    label: const Text("Discard all changes"),
                    onPressed: () {
                      context.read<WorkingDirectoryBloc>().add(
                        UpdateWorkingDirectoryStatus(
                          status: WorkingDirectoryBlocStatus.askForDiscardAllChanges,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];
                  return WorkingDirectoryItem(
                    file: file,
                  );
                },
              ),
            ),
            CommitMessageTextfield(
              hasStagedFiles: state.files.any((file) => file.staged),
            ),
          ],
        );
      },
    );
  }
}
