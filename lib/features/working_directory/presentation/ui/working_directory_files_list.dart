import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/features/working_directory/presentation/ui/stashes_section.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_item.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/commit_message_textfield.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/create_stash_dialog.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_checkbox.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class WorkingDirectoryFilesList extends StatefulWidget {
  const WorkingDirectoryFilesList({super.key});

  @override
  State<WorkingDirectoryFilesList> createState() =>
      _WorkingDirectoryFilesListState();
}

class _WorkingDirectoryFilesListState extends State<WorkingDirectoryFilesList>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  static const double _itemExtent = 40.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _areAllFilesStaged(List<GitFileEntity> files) {
    if (files.isEmpty) return false;
    return files.every((f) => f.staged);
  }

  void _selectFileAtIndex(int index, List<GitFileEntity> files) {
    final file = files[index];
    context.read<WorkingDirectoryBloc>().add(SelectFile(file: file));
    context.read<FilesDifferencesBloc>().add(LoadFileDiff(file: file));
    _scrollToIndex(index);
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final targetOffset = index * _itemExtent;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;

    if (targetOffset < currentOffset) {
      unawaited(
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        ),
      );
    } else if (targetOffset + _itemExtent > currentOffset + viewportHeight) {
      unawaited(
        _scrollController.animateTo(
          targetOffset + _itemExtent - viewportHeight,
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
    final files = state.files;
    if (files.isEmpty) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final currentIndex = state.selectedFile != null
          ? files.indexWhere((f) => f.path == state.selectedFile!.path)
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
        (f) => f.path == selectedFile.path,
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
                    DesktopCheckbox(
                      value: _areAllFilesStaged(state.files),
                      tooltip: 'Stage all files',
                      onChanged: state.files.isEmpty
                          ? null
                          : (checked) {
                              context.read<WorkingDirectoryBloc>().add(
                                ToggleAllFilesStaging(stage: checked),
                              );
                            },
                    ),
                    Expanded(
                      child: DesktopSectionHeader(
                        title: 'Changed files',
                        count: state.files.length.toString(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    DesktopButton(
                      icon: Icons.archive_outlined,
                      label: 'Stash',
                      tooltip: 'Stash local changes',
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
                      label: 'Discard all',
                      tooltip: 'Discard all local changes',
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
                child: state.files.isEmpty
                    ? const DesktopEmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'No local changes',
                        message: 'Your working directory is clean.',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemExtent: _itemExtent,
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
          ),
        );
      },
    );
  }
}
