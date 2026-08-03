import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:open_git/features/branches/presentation/extensions/branch_overview_display_extension.dart";
import "package:open_git/features/branches/presentation/ui/branch_base_status_indicator.dart";
import "package:open_git/features/branches/presentation/ui/branch_sync_status_indicator.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_icon_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";
import "package:open_git/shared/presentation/widgets/snackbars/success_snackbar.dart";

class BranchesOverviewRow extends StatelessWidget {
  final BranchEntity branch;
  final bool selected;
  final ValueChanged<BranchEntity> onSelected;
  final ValueChanged<BranchEntity> onCheckout;
  final ValueChanged<BranchEntity> onDelete;

  const BranchesOverviewRow({
    super.key,
    required this.branch,
    required this.selected,
    required this.onSelected,
    required this.onCheckout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopListRow(
      selected: selected,
      height: 42,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: () {
        onSelected(branch);
      },
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Icon(
                  branch.isCurrent
                      ? Icons.radio_button_checked
                      : Icons.call_split,
                  size: 16,
                  color: branch.isCurrent
                      ? theme.openGit.accent
                      : theme.openGit.textMuted,
                ),
                Gaps.w8,
                Expanded(
                  child: Text(
                    branch.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.openGitBody.copyWith(
                      fontWeight: branch.isCurrent
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                BranchBaseStatusIndicator(branch: branch),
                if (!branch.hasBaseBranchComparison ||
                    branch.name == branch.comparisonBaseBranchName)
                  Text(
                    branch.baseStatusLabel,
                    overflow: TextOverflow.ellipsis,
                    style: theme.openGitCaption.copyWith(
                      color: theme.openGit.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: branch.commitsAhead == 0 && branch.commitsBehind == 0
                ? Text(
                    branch.remoteSyncLabel,
                    overflow: TextOverflow.ellipsis,
                    style: theme.openGitCaption.copyWith(
                      color: theme.openGit.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : BranchSyncStatusIndicator(
                    commitsAhead: branch.commitsAhead,
                    commitsBehind: branch.commitsBehind,
                  ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              branch.lastCommitSummaryLabel,
              overflow: TextOverflow.ellipsis,
              style: theme.openGitCaption.copyWith(
                color: theme.openGit.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 118,
            child: Text(
              branch.lastCommitDateLabel,
              overflow: TextOverflow.ellipsis,
              style: theme.openGitCaption,
            ),
          ),
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DesktopIconButton(
                  icon: Icons.copy,
                  tooltip: "Copy branch name",
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: branch.name));
                    if (!context.mounted) return;

                    SuccessSnackBar.show(
                      context,
                      message: "Branch name copied",
                    );
                  },
                ),
                DesktopIconButton(
                  icon: Icons.login,
                  tooltip: branch.isCurrent ? "Current branch" : "Checkout",
                  onPressed: branch.isCurrent
                      ? null
                      : () {
                          onCheckout(branch);
                        },
                ),
                DesktopIconButton(
                  icon: Icons.delete_outline,
                  tooltip: branch.isCurrent
                      ? "Cannot delete current branch"
                      : "Delete",
                  color: theme.openGit.danger,
                  onPressed: branch.isCurrent
                      ? null
                      : () {
                          onDelete(branch);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
