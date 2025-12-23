import "package:flutter/material.dart";

class PushCommitsButton extends StatelessWidget {
  final int commitsToPush;
  final VoidCallback onPush;
  final bool isLoading;

  const PushCommitsButton({
    super.key,
    required this.commitsToPush,
    required this.onPush,
    this.isLoading = false,
  });

  bool get _hasCommitsToPush => commitsToPush > 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: (_hasCommitsToPush && !isLoading) ? onPush : null,

      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            )
          : Icon(
              _hasCommitsToPush ? Icons.cloud_upload : Icons.cloud_done,
            ),

      label: Text(
        isLoading ? "Pushing..." : (_hasCommitsToPush ? "Push ($commitsToPush)" : "Up to date"),
      ),
    );
  }
}
