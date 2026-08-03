import "package:flutter/material.dart";
import "package:open_git/features/repository/presentation/extensions/repository_fetch_time_display_extension.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class LastFetchStatus extends StatelessWidget {
  final String lastFetchAt;

  const LastFetchStatus({
    super.key,
    required this.lastFetchAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      lastFetchAt.lastFetchLabel,
      overflow: TextOverflow.ellipsis,
      style: theme.openGitCaption.copyWith(
        color: theme.openGit.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
