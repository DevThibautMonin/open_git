import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/graph_commit_entity.dart';

class BranchGraphPainter extends CustomPainter {
  final List<GraphCommitEntity> commits;
  final double rowHeight;
  final double laneWidth;
  final double nodeRadius;
  final double lineWidth;
  final Color baseColor;

  BranchGraphPainter({
    required this.commits,
    this.rowHeight = 24.0,
    this.laneWidth = 14.0,
    this.nodeRadius = 4.0,
    this.lineWidth = 2.0,
    required this.baseColor,
  });

  static const List<Color> _laneColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  Color _getLaneColor(int laneIndex) {
    if (laneIndex < 0) return baseColor;
    return _laneColors[laneIndex % _laneColors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..isAntiAlias = true;

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (int i = 0; i < commits.length; i++) {
      final commit = commits[i];
      final startY = i * rowHeight + (rowHeight / 2);

      for (final route in commit.routes) {
        int targetIndex = commits.indexWhere(
          (c) => c.sha == route.commitSha,
          i + 1,
        );
        if (targetIndex != -1) {
          final endY = targetIndex * rowHeight + (rowHeight / 2);
          final startX = (route.fromLane * laneWidth) + (laneWidth / 2);
          final endX = (route.toLane * laneWidth) + (laneWidth / 2);

          paint.color = _getLaneColor(route.fromLane);

          if (route.fromLane == route.toLane) {
            canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
          } else {
            final path = Path();
            path.moveTo(startX, startY);

            final controlPoint1Y = startY + (endY - startY) * 0.5;
            final controlPoint2Y = startY + (endY - startY) * 0.5;

            path.cubicTo(
              startX,
              controlPoint1Y,
              endX,
              controlPoint2Y,
              endX,
              endY,
            );

            canvas.drawPath(path, paint);
          }
        }
      }
    }

    for (int i = 0; i < commits.length; i++) {
      final commit = commits[i];
      final y = i * rowHeight + (rowHeight / 2);
      final x = (commit.lane * laneWidth) + (laneWidth / 2);

      nodePaint.color = _getLaneColor(commit.lane);
      canvas.drawCircle(Offset(x, y), nodeRadius, nodePaint);

      nodePaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), nodeRadius * 0.4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BranchGraphPainter oldDelegate) {
    return oldDelegate.commits != commits ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.laneWidth != laneWidth;
  }
}
