import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class BranchItem extends StatefulWidget {
  final BranchEntity branch;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDeleteBranch;

  const BranchItem({
    super.key,
    required this.branch,
    required this.onDeleteBranch,
    this.onDoubleTap,
  });

  @override
  State<BranchItem> createState() => _BranchItemState();
}

class _BranchItemState extends State<BranchItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = widget.branch.isCurrent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
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
                onTap: widget.onDeleteBranch,
                child: const Text('Delete branch'),
              ),
            ],
          );
        },
        onDoubleTap: widget.onDoubleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : _hovered
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                Icons.call_split,
                size: 16,
                color: isCurrent ? theme.colorScheme.primary : theme.iconTheme.color?.withValues(alpha: 0.6),
              ),
              Gaps.w8,
              Expanded(
                child: Text(
                  widget.branch.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
