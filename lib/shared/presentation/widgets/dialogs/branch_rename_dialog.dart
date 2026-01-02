import 'package:flutter/material.dart';

class BranchRenameDialog extends StatefulWidget {
  final String initialName;
  final void Function(String newName) onRename;
  final bool hasUpstream;

  const BranchRenameDialog({
    super.key,
    required this.initialName,
    required this.onRename,
    this.hasUpstream = false,
  });

  @override
  State<BranchRenameDialog> createState() => _BranchRenameDialogState();
}

class _BranchRenameDialogState extends State<BranchRenameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialName);
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Rename branch'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.hasUpstream) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This branch is tracking origin/${widget.initialName} and renaming this branch will not change the branch name on the remote.",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Branch name',
              ),
              onSubmitted: (_) {
                _submit();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            _submit();
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }

  void _submit() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    Navigator.of(context).pop();
    widget.onRename(newName);
  }
}
