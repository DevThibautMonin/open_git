import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/features/working_directory/presentation/extensions/working_directory_file_groups_extension.dart";
import "package:open_git/features/working_directory/presentation/ui/stashes_section.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_file_section.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_staging_area.dart";
import "package:open_git/shared/core/extensions/git_file_entity_extensions.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
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
  final FocusNode _focusNode = FocusNode();
  final ScrollController _stagedScrollController = ScrollController();
  final ScrollController _unstagedScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _focusNode.dispose();
    _stagedScrollController.dispose();
    _unstagedScrollController.dispose();
    super.dispose();
  }

  void _selectFileAtIndex(int index, List<GitFileEntity> files) {
    final file = files[index];
    context.read<WorkingDirectoryBloc>().add(SelectFile(file: file));
    context.read<FilesDifferencesBloc>().add(LoadFileDiff(file: file));
    _scrollToFile(file);
  }

  void _scrollToFile(GitFileEntity file) {
    final state = context.read<WorkingDirectoryBloc>().state;
    final sectionFiles = file.staged ? state.stagedFiles : state.unstagedFiles;
    final index = sectionFiles.indexWhere(file.representsSameChangeAs);
    final scrollController = file.staged
        ? _stagedScrollController
        : _unstagedScrollController;

    if (index == -1 || !scrollController.hasClients) return;

    final itemExtent = WorkingDirectoryFileSection.itemExtent;
    final targetOffset = index * itemExtent;
    final viewportHeight = scrollController.position.viewportDimension;
    final currentOffset = scrollController.offset;

    if (targetOffset < currentOffset) {
      unawaited(
        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        ),
      );
    } else if (targetOffset + itemExtent > currentOffset + viewportHeight) {
      unawaited(
        scrollController.animateTo(
          targetOffset + itemExtent - viewportHeight,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final focusedNode = FocusScope.of(context).focusedChild;
    if (focusedNode != null && focusedNode != _focusNode) {
      return KeyEventResult.ignored;
    }

    final bloc = context.read<WorkingDirectoryBloc>();
    final state = bloc.state;
    final files = state.navigationFiles;
    if (files.isEmpty) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final currentIndex = state.selectedFile != null
          ? files.indexWhere(state.selectedFile!.representsSameChangeAs)
          : -1;

      int newIndex;
      if (currentIndex == -1) {
        newIndex = 0;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        newIndex = (currentIndex + 1).clamp(0, files.length - 1);
      } else {
        newIndex = (currentIndex - 1).clamp(0, files.length - 1);
      }

      if (newIndex != currentIndex) {
        _selectFileAtIndex(newIndex, files);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.space) {
      final selectedFile = state.selectedFile;
      if (selectedFile == null) return KeyEventResult.ignored;

      final currentFile = files.firstWhere(
        selectedFile.representsSameChangeAs,
        orElse: () => selectedFile,
      );

      bloc.add(
        ToggleFileStaging(file: currentFile, stage: !currentFile.staged),
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        final stagedFiles = state.stagedFiles;
        final unstagedFiles = state.unstagedFiles;

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Column(
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
          ),
        );
      },
    );
  }
}
