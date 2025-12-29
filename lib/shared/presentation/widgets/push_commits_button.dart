import 'package:flutter/material.dart';

class PushCommitsButton extends StatelessWidget {
  final int commitsToPush;
  final bool hasUpstream;
  final VoidCallback onPush;
  final bool isLoading;

  const PushCommitsButton({
    super.key,
    required this.commitsToPush,
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
    } else if (commitsToPush > 0) {
      label = "Push ($commitsToPush)";
      icon = Icons.cloud_upload;
    } else {
      label = "Up to date";
      icon = Icons.cloud_done;
      enabled = false;
    }

    return ElevatedButton.icon(
      onPressed: enabled ? onPush : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(isLoading ? "Pushing..." : label),
    );
  }
}
