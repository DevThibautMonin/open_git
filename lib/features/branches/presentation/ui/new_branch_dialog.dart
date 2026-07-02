import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart';

class NewBranchDialog extends StatefulWidget {
  const NewBranchDialog({super.key});

  @override
  State<NewBranchDialog> createState() => _NewBranchDialogState();
}

class _NewBranchDialogState extends State<NewBranchDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      title: 'Create new branch',
      icon: Icons.add,
      width: 380,
      actions: [
        DesktopButton(
          label: "Cancel",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        DesktopButton(
          label: "Create",
          icon: Icons.check,
          variant: DesktopButtonVariant.primary,
          onPressed: () {
            _submit();
          },
        ),
      ],
      child: DesktopTextField(
        controller: _controller,
        focusNode: _focusNode,
        hintText: 'feature/new-branch',
        labelText: 'Branch name',
        onSubmitted: (_) {
          _submit();
        },
      ),
    );
  }
}
