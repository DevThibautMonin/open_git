import 'package:flutter/material.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_button.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_dialog.dart';

class BranchDeleteConfirmationDialog extends StatelessWidget {
  final String branchName;
  final String comparisonBaseBranchName;
  final int unmergedCommitsCount;
  final VoidCallback onDelete;

  const BranchDeleteConfirmationDialog({
    super.key,
    required this.branchName,
    this.comparisonBaseBranchName = "",
    this.unmergedCommitsCount = 0,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnmergedCommits =
        comparisonBaseBranchName.isNotEmpty && unmergedCommitsCount > 0;

    return DesktopDialog(
      title: "Delete branch",
      icon: hasUnmergedCommits
          ? Icons.warning_amber_rounded
          : Icons.delete_outline,
      actions: [
        DesktopButton(
          label: "Cancel",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        DesktopButton(
          label: hasUnmergedCommits ? "Delete anyway" : "Delete",
          icon: Icons.delete_outline,
          variant: DesktopButtonVariant.danger,
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            const TextSpan(text: "Are you sure you want to delete the branch "),
            TextSpan(
              text: branchName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: "?"),
            if (hasUnmergedCommits)
              TextSpan(
                text:
                    "\n\nThis branch has $unmergedCommitsCount commits that are not in $comparisonBaseBranchName.",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            const TextSpan(text: "\n\nThis action cannot be undone."),
          ],
        ),
      ),
    );
  }
}
