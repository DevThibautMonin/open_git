import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart';
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
        final theme = Theme.of(context);
        final isCloning =
            state.status == RepositoryBlocStatus.cloning ||
            state.status == RepositoryBlocStatus.cloneProgress;

        final canSubmit =
            _urlController.text.trim().isNotEmpty &&
            state.cloneDestinationPath.isNotEmpty &&
            !isCloning;

        return DesktopDialog(
          title: 'Clone repository',
          icon: Icons.download,
          width: 500,
          actions: [
            DesktopButton(
              label: 'Cancel',
              onPressed: isCloning ? null : () => Navigator.pop(context),
            ),
            DesktopButton(
              label: isCloning ? 'Cloning' : 'Clone',
              icon: Icons.download,
              isLoading: isCloning,
              variant: DesktopButtonVariant.primary,
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
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesktopTextField(
                controller: _urlController,
                enabled: !isCloning,
                onChanged: (_) => setState(() {}),
                labelText: 'SSH repository URL',
                hintText: 'git@github.com:owner/repo.git',
              ),

              Gaps.h20,

              Text(
                'Destination folder',
                style: theme.openGitSectionLabel,
              ),
              Gaps.h8,

              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.openGit.panelAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.openGit.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      state.cloneDestinationPath,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              Gaps.h12,

              DesktopButton(
                icon: Icons.folder_open,
                label: 'Choose folder',
                onPressed: isCloning
                    ? null
                    : () {
                        context.read<RepositoryBloc>().add(
                          ChooseCloneDirectory(),
                        );
                      },
              ),

              if (state.errorMessage.isNotEmpty)
                Text(
                  state.errorMessage,
                  style: TextStyle(color: theme.openGit.danger),
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
        );
      },
    );
  }
}
