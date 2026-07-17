import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/repository/presentation/bloc/repository_bloc.dart";
import "package:open_git/features/repository/presentation/ui/recent_repositories_button.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/fetch_button.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";
import "package:open_git/shared/presentation/widgets/push_commits_button.dart";

class RepositoryHeader extends StatelessWidget {
  final VoidCallback onSelectRepository;
  final VoidCallback onCloneRepository;
  final ValueChanged<String> onRecentRepositorySelected;
  final int commitsToPush;
  final Function() onPush;
  final bool isLoading;
  final bool hasUpstream;

  const RepositoryHeader({
    super.key,
    required this.onSelectRepository,
    required this.commitsToPush,
    required this.onPush,
    required this.isLoading,
    required this.onCloneRepository,
    required this.onRecentRepositorySelected,
    required this.hasUpstream,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      color: theme.openGit.toolbar,
      bottomBorder: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Wrap(
            spacing: 6,
            children: [
              DesktopButton(
                icon: Icons.download,
                label: "Clone",
                tooltip: "Clone repository",
                onPressed: onCloneRepository,
              ),
              DesktopButton(
                icon: Icons.folder_open,
                label: "Open",
                tooltip: "Open local repository",
                onPressed: onSelectRepository,
              ),
            ],
          ),
          Gaps.w16,
          Expanded(
            child: BlocBuilder<RepositoryBloc, RepositoryState>(
              builder: (context, state) {
                final hasRepository = state.currentRepositoryName.isNotEmpty;

                return RecentRepositoriesButton(
                  currentRepositoryName: hasRepository
                      ? state.currentRepositoryName
                      : "",
                  currentRepositoryPath: state.repositoryPath,
                  recentRepositoryPaths: state.recentRepositoryPaths,
                  onOpenRepository: onSelectRepository,
                  onRepositorySelected: onRecentRepositorySelected,
                );
              },
            ),
          ),
          Gaps.w8,
          BlocBuilder<RepositoryBloc, RepositoryState>(
            builder: (context, state) {
              return FetchButton(
                onFetch: () {
                  context.read<RepositoryBloc>().add(FetchRepository());
                },
                isLoading: state.status == RepositoryBlocStatus.fetching,
              );
            },
          ),
          Gaps.w8,
          PushCommitsButton(
            commitsToPush: commitsToPush,
            onPush: onPush,
            isLoading: isLoading,
            hasUpstream: hasUpstream,
          ),
        ],
      ),
    );
  }
}
