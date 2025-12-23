import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class CloneRepositoryDialog extends StatefulWidget {
  const CloneRepositoryDialog({super.key});

  @override
  State<CloneRepositoryDialog> createState() => _CloneRepositoryDialogState();
}

class _CloneRepositoryDialogState extends State<CloneRepositoryDialog> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoryBloc, RepositoryState>(
      builder: (context, state) {
        final isCloning = state.status == RepositoryBlocStatus.cloning || state.status == RepositoryBlocStatus.cloneProgress;

        final canSubmit = _urlController.text.trim().isNotEmpty && state.cloneDestinationPath.isNotEmpty && !isCloning;

        return AlertDialog(
          title: const Text('Clone repository'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _urlController,
                  enabled: !isCloning,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'SSH repository URL',
                    hintText: 'git@github.com:owner/repo.git',
                  ),
                ),

                Gaps.h20,

                Text(
                  'Destination folder',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Gaps.h8,

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    state.cloneDestinationPath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Gaps.h12,

                TextButton.icon(
                  onPressed: isCloning
                      ? null
                      : () {
                          context.read<RepositoryBloc>().add(ChooseCloneDirectory());
                        },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose folder'),
                ),

                if (isCloning) ...[
                  Gaps.h20,
                  LinearProgressIndicator(value: state.cloneProgress),
                  Gaps.h8,
                  Text(
                    '${(state.cloneProgress * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCloning ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: canSubmit
                  ? () {
                      context.read<RepositoryBloc>().add(
                        CloneRepositoryConfirmed(
                          sshUrl: _urlController.text.trim(),
                          destinationPath: state.cloneDestinationPath,
                        ),
                      );
                    }
                  : null,
              child: isCloning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Clone'),
            ),
          ],
        );
      },
    );
  }
}
