import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/shared/domain/entities/git_stash_entity.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_list_row.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class StashItem extends StatelessWidget {
  final GitStashEntity stash;

  const StashItem({
    super.key,
    required this.stash,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopListRow(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onDoubleTap: () {
        context.read<WorkingDirectoryBloc>().add(
          ApplyStash(stash: stash),
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            size: 15,
            color: theme.openGit.textMuted,
          ),
          Gaps.w8,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stash.message.isEmpty ? stash.reference : stash.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textPrimary,
                  ),
                ),
                Text(
                  "${stash.reference} • ${stash.age}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.openGitCaption.copyWith(
                    color: theme.openGit.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: "Stash actions",
            icon: Icon(
              Icons.more_horiz,
              size: 15,
              color: theme.openGit.textMuted,
            ),
            onSelected: (action) {
              if (action == "apply") {
                context.read<WorkingDirectoryBloc>().add(
                  ApplyStash(stash: stash),
                );
              }

              if (action == "pop") {
                context.read<WorkingDirectoryBloc>().add(
                  PopStash(stash: stash),
                );
              }

              if (action == "drop") {
                context.read<WorkingDirectoryBloc>().add(
                  DropStash(stash: stash),
                );
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: "apply",
                  child: Row(
                    children: [
                      Icon(Icons.download_done, size: 16),
                      Gaps.w8,
                      Text("Apply stash"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "pop",
                  child: Row(
                    children: [
                      Icon(Icons.move_down, size: 16),
                      Gaps.w8,
                      Text("Pop stash"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "drop",
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16),
                      Gaps.w8,
                      Text("Drop stash"),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
