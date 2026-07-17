import "package:flutter/material.dart";
import "package:open_git/features/repository/presentation/ui/recent_repositories_menu.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class RecentRepositoriesButton extends StatelessWidget {
  final String currentRepositoryName;
  final String currentRepositoryPath;
  final List<String> recentRepositoryPaths;
  final VoidCallback onOpenRepository;
  final ValueChanged<String> onRepositorySelected;

  const RecentRepositoriesButton({
    super.key,
    required this.currentRepositoryName,
    required this.currentRepositoryPath,
    required this.recentRepositoryPaths,
    required this.onOpenRepository,
    required this.onRepositorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRepository = currentRepositoryName.isNotEmpty;
    final enabled = hasRepository || recentRepositoryPaths.isNotEmpty;

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.openGit.panel),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
      ),
      menuChildren: [
        Builder(
          builder: (menuContext) {
            return RecentRepositoriesMenu(
              currentRepositoryPath: currentRepositoryPath,
              recentRepositoryPaths: recentRepositoryPaths,
              onOpenRepository: () {
                MenuController.maybeOf(menuContext)?.close();
                onOpenRepository();
              },
              onRepositorySelected: (path) {
                MenuController.maybeOf(menuContext)?.close();
                onRepositorySelected(path);
              },
            );
          },
        ),
      ],
      builder: (context, controller, child) {
        return Tooltip(
          message: enabled ? "Switch repository" : "Open local repository",
          waitDuration: const Duration(milliseconds: 450),
          child: MouseRegion(
            opaque: false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (recentRepositoryPaths.isEmpty) {
                  onOpenRepository();
                  return;
                }

                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.openGit.panelAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.openGit.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasRepository
                          ? Icons.data_object
                          : Icons.folder_off_outlined,
                      size: 16,
                      color: hasRepository
                          ? theme.openGit.accent
                          : theme.openGit.textMuted,
                    ),
                    Gaps.w8,
                    Expanded(
                      child: Text(
                        hasRepository
                            ? currentRepositoryName
                            : "No repository selected",
                        overflow: TextOverflow.ellipsis,
                        style: theme.openGitBody.copyWith(
                          fontWeight: FontWeight.w700,
                          color: hasRepository
                              ? theme.openGit.textPrimary
                              : theme.openGit.textMuted,
                        ),
                      ),
                    ),
                    Gaps.w8,
                    Icon(
                      Icons.expand_more,
                      size: 16,
                      color: theme.openGit.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
