import 'package:flutter/material.dart';

class PushCommitsButton extends StatelessWidget {
  final int commitsToPush;
  final VoidCallback onPush;

  const PushCommitsButton({
    super.key,
    required this.commitsToPush,
    required this.onPush,
  });

  bool get _hasCommitsToPush => commitsToPush > 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _hasCommitsToPush ? onPush : null,
      icon: Icon(
        _hasCommitsToPush ? Icons.cloud_upload : Icons.cloud_done,
      ),
      label: Text(
        _hasCommitsToPush ? 'Push ($commitsToPush)' : 'Up to date',
      ),
    );
  }
}
