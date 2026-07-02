import 'package:flutter/material.dart';
import 'package:open_git/features/repository/domain/repository_view_mode.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

class RepositorySidebarNavigation extends StatelessWidget {
  final RepositoryViewMode selectedMode;
  final ValueChanged<RepositoryViewMode> onModeSelected;

  const RepositorySidebarNavigation({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.openGit.panelAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.openGit.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              RepositorySidebarNavigationItem(
                label: 'Branches',
                icon: Icons.account_tree_outlined,
                selected: selectedMode == RepositoryViewMode.branches,
                onTap: () => onModeSelected(RepositoryViewMode.branches),
              ),
              RepositorySidebarNavigationItem(
                label: 'Changes',
                icon: Icons.edit_note,
                selected: selectedMode == RepositoryViewMode.changes,
                onTap: () => onModeSelected(RepositoryViewMode.changes),
              ),
              RepositorySidebarNavigationItem(
                label: 'History',
                icon: Icons.history,
                selected: selectedMode == RepositoryViewMode.commitHistory,
                onTap: () => onModeSelected(RepositoryViewMode.commitHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RepositorySidebarNavigationItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RepositorySidebarNavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<RepositorySidebarNavigationItem> createState() =>
      RepositorySidebarNavigationItemState();
}

class RepositorySidebarNavigationItemState
    extends State<RepositorySidebarNavigationItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: MouseRegion(
        opaque: false,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: widget.selected
                  ? theme.openGit.panel
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.selected
                    ? theme.openGit.selectedBorder
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 15,
                  color: widget.selected
                      ? theme.openGit.accent
                      : theme.openGit.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.selected
                          ? theme.openGit.textPrimary
                          : theme.openGit.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
