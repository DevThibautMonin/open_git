import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_item.dart';
import 'package:open_git/shared/presentation/widgets/commit_message_textfield.dart';

class WorkingDirectoryFilesList extends StatefulWidget {
  const WorkingDirectoryFilesList({super.key});

  @override
  State<WorkingDirectoryFilesList> createState() => _WorkingDirectoryFilesListState();
}

class _WorkingDirectoryFilesListState extends State<WorkingDirectoryFilesList> with AutomaticKeepAliveClientMixin {
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

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      final currentIndex = state.selectedFile != null ? files.indexWhere((f) => f.path == state.selectedFile!.path) : -1;

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

      bloc.add(ToggleFileStaging(file: currentFile, stage: !currentFile.staged));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        if (state.files.isEmpty) {
          return const Center(
            child: Text("No local changes"),
          );
        }
        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Column(
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
