import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/graph/branch_graph_commit_row.dart';
import 'package:open_git/features/branches/presentation/ui/graph/branch_graph_painter.dart';
import 'package:open_git/shared/domain/entities/graph_commit_entity.dart';

class BranchGraphScreen extends StatelessWidget {
  final List<GraphCommitEntity> commits;
  final double rowHeight;
  final double laneWidth;
  final ScrollController? scrollController;

  const BranchGraphScreen({
    super.key,
    required this.commits,
    this.rowHeight = 28.0,
    this.laneWidth = 14.0,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (commits.isEmpty) {
      return const Center(
        child: Text("No commits found."),
      );
    }

    final maxLane = commits.map((c) => c.lane).reduce((a, b) => a > b ? a : b);
    final graphWidth = (maxLane + 1) * laneWidth + 10.0;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: scrollController,
      child: Stack(
        children: [
          // Graph layer
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: graphWidth,
            child: CustomPaint(
              size: Size(graphWidth, commits.length * rowHeight),
              painter: BranchGraphPainter(
                commits: commits,
                rowHeight: rowHeight,
                laneWidth: laneWidth,
                baseColor: theme.colorScheme.primary,
              ),
            ),
          ),
          
          // Commits list layer
          Padding(
            padding: EdgeInsets.only(left: graphWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(commits.length, (index) {
                final commit = commits[index];
                
                return BranchGraphCommitRow(
                  commit: commit,
                  rowHeight: rowHeight,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
