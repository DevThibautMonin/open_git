import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/presentation/widgets/commit_button.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart';

class CommitMessageTextfield extends StatefulWidget {
  final bool hasStagedFiles;

  const CommitMessageTextfield({
    super.key,
    required this.hasStagedFiles,
  });

  @override
  State<CommitMessageTextfield> createState() => _CommitMessageTextfieldState();
}

class _CommitMessageTextfieldState extends State<CommitMessageTextfield> {
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _summaryController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _summaryController.removeListener(_onTextChanged);
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isCommitEnabled {
    return widget.hasStagedFiles && _summaryController.text.trim().isNotEmpty;
  }

  void _onCommit() {
    if (!_isCommitEnabled) return;

    context.read<WorkingDirectoryBloc>().add(
      AddCommit(
        summary: _summaryController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );

    _summaryController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      topBorder: true,
      color: theme.openGit.toolbar,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Commit',
            style: theme.openGitSectionLabel,
          ),
          Gaps.h8,
          DesktopTextField(
            controller: _summaryController,
            maxLength: 50,
            labelText: 'Summary',
            hintText: 'Short summary of the commit',
          ),
          const SizedBox(height: 8),
          DesktopTextField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'More detailed explanation...',
            maxLines: 4,
          ),
          Gaps.h8,
          CommitButton(
            text: widget.hasStagedFiles ? 'Commit' : 'No staged files',
            onPressed: _onCommit,
            isEnabled: _isCommitEnabled,
          ),
        ],
      ),
    );
  }
}
