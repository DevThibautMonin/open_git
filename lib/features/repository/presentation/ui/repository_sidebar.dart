import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branches_sidebar.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/features/working_directory/presentation/ui/working_directory_files_list.dart';
import 'package:open_git/features/commit_history/presentation/ui/commit_history_list.dart';

class RepositorySidebar extends StatelessWidget {
  const RepositorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Container(
        width: 400,
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
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: (index) {
                final bloc = context.read<RepositoryBloc>();
                switch (index) {
                  case 1:
                    bloc.add(
                      SetRepositoryViewMode(
                        mode: RepositoryViewMode.changes,
                      ),
                    );
                    break;
                  case 2:
                    bloc.add(
                      SetRepositoryViewMode(
                        mode: RepositoryViewMode.commitHistory,
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
              tabs: [
                Tab(text: "Branches"),
                Tab(text: "Changes"),
                Tab(text: "History"),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  BranchesSidebar(),
                  WorkingDirectoryFilesList(),
                  BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          Expanded(
                            child: CommitHistoryList(
                              commits: state.commits,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<RepositoryBloc, RepositoryState>(
              buildWhen: (previous, current) => previous.version != current.version,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Version : ${state.version}"),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () async {
                          await autoUpdater.checkForUpdates(inBackground: false);
                        },
                        child: const Icon(
                          Icons.refresh,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
