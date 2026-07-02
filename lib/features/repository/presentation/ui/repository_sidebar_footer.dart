import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/themes/bloc/theme_bloc.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_icon_button.dart';

class RepositorySidebarFooter extends StatelessWidget {
  const RepositorySidebarFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.openGit.toolbar,
        border: Border(
          top: BorderSide(color: theme.openGit.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: BlocBuilder<RepositoryBloc, RepositoryState>(
          buildWhen: (previous, current) => previous.version != current.version,
          builder: (context, state) {
            final isDark =
                context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;
            final theme = Theme.of(context);

            return Row(
              children: [
                DesktopIconButton(
                  icon: isDark ? Icons.light_mode : Icons.dark_mode,
                  tooltip: isDark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  onPressed: () {
                    context.read<ThemeBloc>().add(UpdateTheme());
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    state.version.isEmpty
                        ? 'OpenGit'
                        : 'OpenGit ${state.version}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.openGitCaption,
                  ),
                ),
                DesktopIconButton(
                  icon: Icons.refresh,
                  tooltip: 'Check for updates',
                  onPressed: () async {
                    await autoUpdater.checkForUpdates(inBackground: false);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
