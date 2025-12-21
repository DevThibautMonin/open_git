import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branches_sidebar.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_files_list.dart';

class RepositorySidebar extends StatelessWidget {
  final List<BranchEntity> branches;
  final List<GitFileEntity> files;
  final VoidCallback onNewBranch;
  final ValueChanged<GitFileEntity> onCheckboxToggled;
  final Function(GitFileEntity file) onFileSelected;

  const RepositorySidebar({
    super.key,
    required this.branches,
    required this.files,
    required this.onNewBranch,
    required this.onCheckboxToggled,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            right: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Branches"),
                Tab(text: "Changes (${files.length})"),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  BranchesSidebar(
                    branches: branches,
                    onNewBranch: onNewBranch,
                  ),
                  WorkingDirectoryFilesList(
                    files: files,
                    onCheckboxToggled: onCheckboxToggled,
                    onFileSelected: (file) {
                      onFileSelected(file);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
