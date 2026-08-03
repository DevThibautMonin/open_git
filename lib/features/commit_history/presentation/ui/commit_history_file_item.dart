import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/services.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/shared/core/extensions/string_extensions.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart";
import "package:open_git/shared/presentation/widgets/file_type_icon.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";
import "package:open_git/shared/presentation/widgets/snackbars/success_snackbar.dart";

class CommitHistoryFileItem extends StatelessWidget {
  final String filePath;
  final VoidCallback onTap;

  const CommitHistoryFileItem({
    super.key,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitHistoryBloc, CommitHistoryState>(
      builder: (context, state) {
        final isSelected = state.selectedCommitFile == filePath;
        final theme = Theme.of(context);

        return DesktopListRow(
          selected: isSelected,
          onTap: onTap,
          onSecondaryTapDown: (details) async {
            onTap();
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
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: filePath));
                    if (!context.mounted) return;

                    SuccessSnackBar.show(
                      context,
                      message: "File path copied",
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 16),
                      Gaps.w8,
                      Text("Copy file path"),
                    ],
                  ),
                ),
              ],
            );
          },
          child: Row(
            children: [
              FileTypeIcon(type: filePath.fileType),
              Gaps.w8,
              Expanded(
                child: Text(
                  filePath,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
