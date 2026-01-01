import 'package:flutter/material.dart';

class BranchRenameDialog extends StatefulWidget {
  final String initialName;
  final void Function(String newName) onRename;

  const BranchRenameDialog({
    super.key,
    required this.initialName,
    required this.onRename,
  });

  @override
  State<BranchRenameDialog> createState() => _BranchRenameDialogState();
}

class _BranchRenameDialogState extends State<BranchRenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename branch'),
      content: SizedBox(
        width: 500,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Branch name',
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
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
