import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branches_sidebar.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_sidebar.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/features/repository/presentation/ui/repository_sidebar_footer.dart';
import 'package:open_git/features/repository/presentation/ui/repository_sidebar_navigation.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_files_list.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';

class RepositorySidebar extends StatelessWidget {
  const RepositorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopPanel(
      rightBorder: true,
      child: BlocBuilder<RepositoryBloc, RepositoryState>(
        buildWhen: (previous, current) =>
            previous.repositoryViewMode != current.repositoryViewMode,
        builder: (context, state) {
          final selectedMode =
              state.repositoryViewMode ?? RepositoryViewMode.changes;

          return Column(
            children: [
              RepositorySidebarNavigation(
                selectedMode: selectedMode,
                onModeSelected: (mode) {
                  context.read<RepositoryBloc>().add(
                    SetRepositoryViewMode(mode: mode),
                  );

                  if (mode == RepositoryViewMode.commitHistory) {
                    context.read<CommitHistoryBloc>().add(LoadCommitHistory());
                  }
                },
              ),
              Expanded(
                child: switch (selectedMode) {
                  RepositoryViewMode.branches => const BranchesSidebar(),
                  RepositoryViewMode.commitHistory =>
                    const CommitHistorySidebar(),
                  RepositoryViewMode.changes =>
                    const WorkingDirectoryFilesList(),
                },
              ),
              const RepositorySidebarFooter(),
            ],
          );
        },
      ),
    );
  }
}
