import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

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

    context.read<WorkingDirectoryBloc>().add(AddCommit(summary: _summaryController.text.trim(), description: _descriptionController.text.trim()));

    _summaryController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _summaryController,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Summary',
              hintText: 'Short summary of the commit',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'More detailed explanation...',
              border: OutlineInputBorder(),
            ),
          ),
          Gaps.h8,
          ElevatedButton(
            onPressed: _isCommitEnabled ? _onCommit : null,
            child: Text(
              widget.hasStagedFiles ? 'Commit' : 'No staged files',
            ),
          ),
        ],
      ),
    );
  }
}
