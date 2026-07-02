import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class BranchItem extends StatelessWidget {
  final BranchEntity branch;

  const BranchItem({
    super.key,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = branch.isCurrent;
    final theme = Theme.of(context);

    return DesktopListRow(
      selected: isCurrent,
      onSecondaryTapDown: (details) async {
        await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            PopupMenuItem(
              onTap: () {
                context.read<BranchesBloc>().add(
                  AskForRenamingBranch(branch: branch),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16),
                  Gaps.w8,
                  Text('Rename branch'),
                ],
              ),
            ),
            if (!branch.isCurrent)
              PopupMenuItem(
                onTap: () {
                  context.read<BranchesBloc>()
                    ..add(UpdateSelectedBranch(branch: branch))
                    ..add(
                      UpdateBranchesStatus(
                        status: BranchesBlocStatus.askForDeletingBranch,
                      ),
                    );
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16),
                    Gaps.w8,
                    Text('Delete branch'),
                  ],
                ),
              ),
          ],
        );
      },
      onDoubleTap: () {
        final bloc = context.read<BranchesBloc>();

        if (branch.isRemote && !branch.existsLocally) {
          bloc.add(
            CheckoutRemoteBranch(
              branch: branch,
            ),
          );
        } else {
          bloc.add(
            SwitchToBranch(
              branch: branch,
            ),
          );
        }
      },
      child: Row(
        children: [
          Icon(
            branch.isRemote ? Icons.cloud_outlined : Icons.call_split,
            size: 16,
            color: isCurrent
                ? theme.openGit.accent
                : theme.openGit.textMuted,
          ),
          Gaps.w8,
          Expanded(
            child: Text(
              branch.name,
              overflow: TextOverflow.ellipsis,
              style: theme.openGitBody.copyWith(
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (branch.deletedOnRemote && !branch.isCurrent)
            Tooltip(
              message: "Branch deleted on remote. You can delete it safely.",
              child: Icon(
                Icons.warning_amber_rounded,
                size: 17,
                color: theme.openGit.warning,
              ),
            ),
        ],
      ),
    );
  }
}
