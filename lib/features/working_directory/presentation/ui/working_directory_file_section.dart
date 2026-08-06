import "package:flutter/material.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_item.dart";
import "package:open_git/features/working_directory/presentation/ui/working_directory_section_empty_state.dart";
import "package:open_git/shared/domain/entities/git_file_entity.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart";

class WorkingDirectoryFileSection extends StatelessWidget {
  static const double itemExtent = 40;

  final String title;
  final List<GitFileEntity> files;
  final ScrollController scrollController;
  final Widget? trailing;
  final String emptyTitle;
  final IconData emptyIcon;

  const WorkingDirectoryFileSection({
    super.key,
    required this.title,
    required this.files,
    required this.scrollController,
    required this.emptyTitle,
    required this.emptyIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DesktopSectionHeader(
          title: title,
          count: files.length.toString(),
          trailing: trailing,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        ),
        Expanded(
          child: files.isEmpty
              ? WorkingDirectorySectionEmptyState(
                  icon: emptyIcon,
                  title: emptyTitle,
                )
              : ListView.builder(
                  controller: scrollController,
                  itemExtent: itemExtent,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return WorkingDirectoryItem(file: files[index]);
                  },
                ),
        ),
      ],
    );
  }
}
