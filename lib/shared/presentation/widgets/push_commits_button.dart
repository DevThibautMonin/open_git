import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";

class PushCommitsButton extends StatelessWidget {
  final int commitsToPush;
  final int commitsToPull;
  final bool hasUpstream;
  final VoidCallback onPush;
  final bool isLoading;

  const PushCommitsButton({
    super.key,
    required this.commitsToPush,
    required this.commitsToPull,
    required this.hasUpstream,
    required this.onPush,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    bool enabled = !isLoading;

    if (!hasUpstream) {
      label = "Publish branch";
      icon = Icons.cloud_upload;
    } else if (commitsToPush > 0 && commitsToPull > 0) {
      label = "Pull first";
      icon = Icons.sync_problem;
      enabled = false;
    } else if (commitsToPush > 0) {
      label = "Push ($commitsToPush)";
      icon = Icons.cloud_upload;
    } else if (commitsToPull > 0) {
      label = "No commits to push";
      icon = Icons.cloud_done;
      enabled = false;
    } else {
      label = "Up to date";
      icon = Icons.cloud_done;
      enabled = false;
    }

    return DesktopButton(
      icon: icon,
      label: isLoading ? "Pushing" : label,
      tooltip: commitsToPush > 0 && commitsToPull > 0
          ? "Pull remote commits before pushing"
          : label,
      isLoading: isLoading,
      variant: enabled
          ? DesktopButtonVariant.primary
          : DesktopButtonVariant.subtle,
      onPressed: enabled ? onPush : null,
    );
  }
}
