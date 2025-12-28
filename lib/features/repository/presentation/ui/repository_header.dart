import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';
import 'package:open_git/shared/presentation/widgets/push_commits_button.dart';

class RepositoryHeader extends StatelessWidget {
  final VoidCallback onSelectRepository;
  final VoidCallback onCloneRepository;
  final int commitsToPush;
  final Function() onPush;
  final bool isLoading;

  const RepositoryHeader({
    super.key,
    required this.onSelectRepository,
    required this.commitsToPush,
    required this.onPush,
    required this.isLoading,
    required this.onCloneRepository,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(
                  Icons.download,
                  size: 18,
                ),
                label: const Text('Clone'),
                onPressed: onCloneRepository,
              ),
              ActionChip(
                avatar: const Icon(
                  Icons.folder_open,
                  size: 18,
                ),
                label: const Text('Open'),
                onPressed: onSelectRepository,
              ),
            ],
          ),
          Gaps.w16,
          Expanded(
            child: BlocBuilder<RepositoryBloc, RepositoryState>(
              builder: (context, state) {
                return Text(
                  state.currentRepositoryName.isEmpty ? "No repository selected" : state.currentRepositoryName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          PushCommitsButton(
            commitsToPush: commitsToPush,
            onPush: onPush,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
