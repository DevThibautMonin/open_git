import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';

class FetchButton extends StatelessWidget {
  final VoidCallback onFetch;
  final bool isLoading;

  const FetchButton({
    super.key,
    required this.onFetch,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopButton(
      icon: Icons.sync,
      label: isLoading ? "Fetching" : "Fetch",
      tooltip: "Fetch remote updates",
      isLoading: isLoading,
      onPressed: isLoading ? null : onFetch,
    );
  }
}
