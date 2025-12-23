import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branches_sidebar.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_files_list.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_list.dart';

class RepositorySidebar extends StatelessWidget {
  final List<BranchEntity> branches;
  final List<GitFileEntity> files;
  final VoidCallback onNewBranch;
  final Function(GitFileEntity file) onFileSelected;
  final bool hasStagedFiles;
  final void Function({
    required String summary,
    required String description,
  })
  onCommitPressed;

  const RepositorySidebar({
    super.key,
    required this.branches,
    required this.files,
    required this.onNewBranch,
    required this.onFileSelected,
    required this.hasStagedFiles,
    required this.onCommitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
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
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: [
                Tab(text: "Branches"),
                Tab(text: "Changes (${files.length})"),
                Tab(text: "History"),
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
                    onFileSelected: (file) {
                      onFileSelected(file);
                    },
                    hasStagedFiles: hasStagedFiles,
                    onCommitPressed: onCommitPressed,
                  ),
                  BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
                    bloc: context.read<CommitHistoryBloc>(),
                    builder: (context, state) {
                      return CommitHistoryList(commits: state.commits);
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
