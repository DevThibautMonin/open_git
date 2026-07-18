import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";

class PullButton extends StatelessWidget {
  final VoidCallback onPull;
  final bool isLoading;

  const PullButton({
    super.key,
    required this.onPull,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopButton(
      icon: Icons.cloud_download,
      label: isLoading ? "Pulling" : "Pull",
      tooltip: "Pull remote updates safely",
      isLoading: isLoading,
      onPressed: isLoading ? null : onPull,
    );
  }
}
