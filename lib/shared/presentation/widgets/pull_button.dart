import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";

class PullButton extends StatelessWidget {
  final VoidCallback onPull;
  final bool isLoading;
  final int commitsToPull;

  const PullButton({
    super.key,
    required this.onPull,
    this.isLoading = false,
    this.commitsToPull = 0,
  });

  @override
  Widget build(BuildContext context) {
    final label = commitsToPull > 0 ? "Pull ($commitsToPull)" : "Pull";

    return DesktopButton(
      icon: Icons.cloud_download,
      label: isLoading ? "Pulling" : label,
      tooltip: commitsToPull > 0
          ? "$commitsToPull remote commits ready to pull"
          : "Pull remote updates safely",
      isLoading: isLoading,
      onPressed: isLoading ? null : onPull,
    );
  }
}
