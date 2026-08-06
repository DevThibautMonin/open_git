import "package:flutter/material.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_file_section.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class WorkingDirectoryStagingArea extends StatelessWidget {
  final List<GitFileEntity> stagedFiles;
  final List<GitFileEntity> unstagedFiles;
  final ScrollController stagedScrollController;
  final ScrollController unstagedScrollController;
  final VoidCallback? onStageAll;
  final VoidCallback? onUnstageAll;

  const WorkingDirectoryStagingArea({
    super.key,
    required this.stagedFiles,
    required this.unstagedFiles,
    required this.stagedScrollController,
    required this.unstagedScrollController,
    this.onStageAll,
    this.onUnstageAll,
  });

  @override
  Widget build(BuildContext context) {
    if (stagedFiles.isEmpty && unstagedFiles.isEmpty) {
      return const DesktopEmptyState(
        icon: Icons.check_circle_outline,
        title: "No local changes",
        message: "Your working directory is clean.",
      );
    }

    final stagedSection = WorkingDirectoryFileSection(
      title: "Staged changes",
      files: stagedFiles,
      scrollController: stagedScrollController,
      emptyIcon: Icons.inventory_2_outlined,
      emptyTitle: "No staged changes",
      trailing: DesktopButton(
        icon: Icons.remove_done,
        label: "Unstage all",
        tooltip: "Unstage all staged changes",
        onPressed: stagedFiles.isEmpty ? null : onUnstageAll,
      ),
    );

    final unstagedSection = WorkingDirectoryFileSection(
      title: "Changes",
      files: unstagedFiles,
      scrollController: unstagedScrollController,
      emptyIcon: Icons.folder_open,
      emptyTitle: "No unstaged changes",
      trailing: DesktopButton(
        icon: Icons.add_task,
        label: "Stage all",
        tooltip: "Stage all unstaged changes",
        onPressed: unstagedFiles.isEmpty ? null : onStageAll,
      ),
    );

    if (stagedFiles.isEmpty) {
      return Column(
        children: [
          SizedBox(
            height: 106,
            child: stagedSection,
          ),
          Expanded(child: unstagedSection),
        ],
      );
    }

    if (unstagedFiles.isEmpty) {
      return Column(
        children: [
          Expanded(child: stagedSection),
          SizedBox(
            height: 106,
            child: unstagedSection,
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: stagedSection),
        Expanded(child: unstagedSection),
      ],
    );
  }
}
