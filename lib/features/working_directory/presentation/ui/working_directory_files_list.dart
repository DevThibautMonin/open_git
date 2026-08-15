import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/features/working_directory/presentation/extensions/working_directory_file_groups_extension.dart";
import "package:open_git/features/working_directory/presentation/ui/stashes_section.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_staging_area.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/commit_message_textfield.dart";
import "package:open_git/shared/presentation/widgets/dialogs/create_stash_dialog.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class WorkingDirectoryFilesList extends StatefulWidget {
  const WorkingDirectoryFilesList({super.key});

  @override
  State<WorkingDirectoryFilesList> createState() =>
      _WorkingDirectoryFilesListState();
}

class _WorkingDirectoryFilesListState extends State<WorkingDirectoryFilesList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _stagedScrollController = ScrollController();
  final ScrollController _unstagedScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _stagedScrollController.dispose();
    _unstagedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        final stagedFiles = state.stagedFiles;
        final unstagedFiles = state.unstagedFiles;

        return Column(
          children: [
            StashesSection(stashes: state.stashes),
            DesktopPanel(
              color: Theme.of(context).openGit.toolbar,
              bottomBorder: true,
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
              child: Row(
                children: [
                  Expanded(
                    child: DesktopSectionHeader(
                      title: "Working directory",
                      count: state.files.length.toString(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  DesktopButton(
                    icon: Icons.archive_outlined,
                    label: "Stash",
                    tooltip: "Stash local changes",
                    onPressed: state.files.isEmpty
                        ? null
                        : () async {
                            final workingDirectoryBloc = context
                                .read<WorkingDirectoryBloc>();

                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return CreateStashDialog(
                                  onCreate: (message) {
                                    workingDirectoryBloc.add(
                                      CreateStash(message: message),
                                    );
                                  },
                                );
                              },
                            );
                          },
                  ),
                  Gaps.w8,
                  DesktopButton(
                    icon: Icons.remove_circle_outline,
                    label: "Discard all",
                    tooltip: "Discard all local changes",
                    variant: DesktopButtonVariant.danger,
                    onPressed: state.files.isEmpty
                        ? null
                        : () {
                            context.read<WorkingDirectoryBloc>().add(
                              UpdateWorkingDirectoryStatus(
                                status: WorkingDirectoryBlocStatus
                                    .askForDiscardAllChanges,
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
            Expanded(
              child: WorkingDirectoryStagingArea(
                stagedFiles: stagedFiles,
                unstagedFiles: unstagedFiles,
                stagedScrollController: _stagedScrollController,
                unstagedScrollController: _unstagedScrollController,
                onStageAll: unstagedFiles.isEmpty
                    ? null
                    : () {
                        context.read<WorkingDirectoryBloc>().add(
                          ToggleAllFilesStaging(stage: true),
                        );
                      },
                onUnstageAll: stagedFiles.isEmpty
                    ? null
                    : () {
                        context.read<WorkingDirectoryBloc>().add(
                          ToggleAllFilesStaging(stage: false),
                        );
                      },
              ),
            ),
            CommitMessageTextfield(hasStagedFiles: stagedFiles.isNotEmpty),
          ],
        );
      },
    );
  }
}
