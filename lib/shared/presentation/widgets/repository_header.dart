import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';
import 'package:open_git/shared/presentation/widgets/push_commits_button.dart';

class RepositoryHeader extends StatelessWidget {
  final String repositoryName;
  final VoidCallback onSelectRepository;
  final VoidCallback onCloneRepository;
  final int commitsToPush;
  final Function() onPush;
  final bool isLoading;

  const RepositoryHeader({
    super.key,
    required this.repositoryName,
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
          ElevatedButton.icon(
            onPressed: onCloneRepository,
            icon: const Icon(Icons.download, size: 18),
            label: const Text("Clone Repository"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
          Gaps.w16,
          ElevatedButton.icon(
            onPressed: onSelectRepository,
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text("Select Repository"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
          Gaps.w16,
          Expanded(
            child: Text(
              repositoryName.isEmpty ? "No repository selected" : repositoryName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
