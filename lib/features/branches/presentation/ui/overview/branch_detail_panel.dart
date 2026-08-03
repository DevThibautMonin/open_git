import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:open_git/features/branches/presentation/extensions/branch_overview_display_extension.dart";
import "package:open_git/features/branches/presentation/ui/overview/branch_detail_metric.dart";
import "package:open_git/shared/domain/entities/branch_entity.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";
import "package:open_git/shared/presentation/widgets/snackbars/success_snackbar.dart";

class BranchDetailPanel extends StatelessWidget {
  final BranchEntity? branch;
  final ValueChanged<BranchEntity> onCheckout;
  final ValueChanged<BranchEntity> onDelete;

  const BranchDetailPanel({
    super.key,
    required this.branch,
    required this.onCheckout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final branch = this.branch;

    if (branch == null) {
      return const DesktopEmptyState(
        icon: Icons.call_split,
        title: "No branch selected",
        message: "Select a branch to inspect its status.",
      );
    }

    final theme = Theme.of(context);
    final hasUnmergedCommits = branch.hasUnmergedBaseBranchCommits;

    return DesktopPanel(
      leftBorder: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                branch.isCurrent
                    ? Icons.radio_button_checked
                    : Icons.call_split,
                size: 17,
                color: branch.isCurrent
                    ? theme.openGit.accent
                    : theme.openGit.textMuted,
              ),
              Gaps.w8,
              Expanded(
                child: Text(
                  branch.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitTitle,
                ),
              ),
            ],
          ),
          Gaps.h16,
          BranchDetailMetric(
            label: "Main status",
            value: branch.baseStatusLabel,
            valueColor: hasUnmergedCommits
                ? theme.openGit.accent
                : theme.openGit.textPrimary,
          ),
          Gaps.h8,
          BranchDetailMetric(
            label: "Remote sync",
            value: branch.remoteSyncLabel,
            valueColor: branch.commitsBehind > 0
                ? theme.openGit.warning
                : theme.openGit.textPrimary,
          ),
          Gaps.h8,
          BranchDetailMetric(
            label: "Last commit",
            value: branch.lastCommitDateLabel,
          ),
          Gaps.h16,
          Text(
            branch.baseStatusDescription,
            style: theme.openGitBody.copyWith(
              color: hasUnmergedCommits
                  ? theme.openGit.accent
                  : theme.openGit.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.h12,
          Text(
            branch.lastCommitSummaryLabel,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.openGitCaption.copyWith(
              color: theme.openGit.textPrimary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DesktopButton(
                icon: Icons.copy,
                label: "Copy",
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
              DesktopButton(
                icon: Icons.login,
                label: branch.isCurrent ? "Current" : "Checkout",
                tooltip: branch.isCurrent
                    ? "Current branch"
                    : "Checkout branch",
                onPressed: branch.isCurrent
                    ? null
                    : () {
                        onCheckout(branch);
                      },
              ),
              DesktopButton(
                icon: Icons.delete_outline,
                label: "Delete",
                tooltip: branch.isCurrent
                    ? "Cannot delete current branch"
                    : "Delete branch",
                variant: DesktopButtonVariant.danger,
                onPressed: branch.isCurrent
                    ? null
                    : () {
                        onDelete(branch);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
