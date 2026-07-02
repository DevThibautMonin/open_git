import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart';

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

    return DesktopDialog(
      title: 'Rename branch',
      icon: Icons.edit_outlined,
      width: 500,
      actions: [
        DesktopButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DesktopButton(
          label: 'Rename',
          icon: Icons.check,
          variant: DesktopButtonVariant.primary,
          onPressed: () {
            _submit();
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hasUpstream) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.openGit.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.openGit.warning.withValues(alpha: 0.28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.openGit.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This branch tracks origin/${widget.initialName}. Renaming it will not rename the remote branch.",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          DesktopTextField(
            controller: _controller,
            focusNode: _focusNode,
            labelText: 'Branch name',
            hintText: 'feature/new-branch',
            onSubmitted: (_) {
              _submit();
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    Navigator.of(context).pop();
    widget.onRename(newName);
  }
}
