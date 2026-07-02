import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/graph/branch_graph_ref_badge.dart';
import 'package:open_git/shared/domain/entities/graph_commit_entity.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';
import 'package:open_git/shared/presentation/widgets/user_avatar.dart';

class BranchGraphCommitRow extends StatefulWidget {
  final GraphCommitEntity commit;
  final double rowHeight;

  const BranchGraphCommitRow({
    super.key,
    required this.commit,
    required this.rowHeight,
  });

  @override
  State<BranchGraphCommitRow> createState() => _BranchGraphCommitRowState();
}

class _BranchGraphCommitRowState extends State<BranchGraphCommitRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      opaque: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: widget.rowHeight,
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  if (widget.commit.refs.isNotEmpty) ...[
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.commit.refs
                              .map((ref) => BranchGraphRefBadge(refName: ref))
                              .toList(),
                        ),
                      ),
                    ),
                    Gaps.w8,
                  ],
                  Expanded(
                    child: Text(
                      widget.commit.message,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.openGitBody.copyWith(
                        fontWeight: widget.commit.refs.isNotEmpty
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.w16,
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  UserAvatar(
                    authorName: widget.commit.author,
                    authorEmail: widget.commit.authorEmail,
                    size: 20.0,
                  ),
                  Gaps.w8,
                  Expanded(
                    child: Text(
                      widget.commit.author,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.openGitCaption,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                "${widget.commit.date.year}-${widget.commit.date.month.toString().padLeft(2, '0')}-${widget.commit.date.day.toString().padLeft(2, '0')}",
                textAlign: TextAlign.right,
                style: theme.openGitCaption,
              ),
            ),
            Gaps.w16,
            SizedBox(
              width: 60,
              child: Text(
                widget.commit.sha.substring(0, 7),
                textAlign: TextAlign.right,
                style: theme.openGitCaption.copyWith(
                  fontFamily: 'monospace',
                  color: theme.openGit.textMuted,
                ),
              ),
            ),
            Gaps.w16,
          ],
        ),
      ),
    );
  }
}
