import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/git_commands.dart';
import 'package:open_git/shared/core/services/git_command_runner.dart';
import 'package:open_git/shared/domain/entities/graph_commit_entity.dart';
import 'package:open_git/shared/domain/entities/graph_route.dart';
import 'package:open_git/shared/domain/failures/git_service_failure.dart';

@LazySingleton()
class GitGraphService {
  final GitCommandRunner commandRunner;

  GitGraphService({
    required this.commandRunner,
  });

  Future<Either<GitServiceFailure, List<GraphCommitEntity>>> getGraphCommits({
    int limit = 1000,
  }) async {
    final logResult = await commandRunner.run([
      ...GitCommands.gitLogGraphAll,
      '-n',
      limit.toString(),
    ]);

    if (logResult.isLeft) {
      return Left(logResult.left);
    }

    final output = logResult.right;
    final lines = output.split('\x00').where((l) => l.trim().isNotEmpty).toList();

    return Right(_parseGraph(lines));
  }

  List<GraphCommitEntity> _parseGraph(List<String> lines) {
    if (lines.isEmpty) return [];

    final result = <GraphCommitEntity>[];
    
    // Track active branches by their current expected commit SHA
    final List<String?> activeBranches = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final p = line.split('|').map((e) => e.trim()).toList();
      
      if (p.length < 7) continue;

      final sha = p[0];
      final parentsStr = p[1];
      final refsStr = p[2];
      final author = p[3];
      final authorEmail = p[4];
      final dateStr = p[5];
      final message = p[6];

      final parents = parentsStr.split(' ').where((e) => e.isNotEmpty).toList();
      final refs = refsStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Find the lane for this commit
      int laneIndex = activeBranches.indexOf(sha);
      
      // If we don't have a lane for it, find the first empty lane or add a new one
      if (laneIndex == -1) {
        laneIndex = activeBranches.indexWhere((b) => b == null);
        if (laneIndex == -1) {
          laneIndex = activeBranches.length;
          activeBranches.add(sha);
        } else {
          activeBranches[laneIndex] = sha;
        }
      }

      final routes = <GraphRoute>[];

      // Update activeBranches based on parents
      if (parents.isEmpty) {
        // End of this branch
        activeBranches[laneIndex] = null;
      } else {
        // Primary parent takes the current lane
        activeBranches[laneIndex] = parents.first;
        routes.add(GraphRoute(fromLane: laneIndex, toLane: laneIndex, commitSha: parents.first));

        // Additional parents (merges) get new lanes
        for (int pIndex = 1; pIndex < parents.length; pIndex++) {
          final parent = parents[pIndex];
          
          // Does this parent already have a lane?
          int parentLane = activeBranches.indexOf(parent);
          
          if (parentLane == -1) {
            // Find empty or add new
            parentLane = activeBranches.indexWhere((b) => b == null);
            if (parentLane == -1) {
              parentLane = activeBranches.length;
              activeBranches.add(parent);
            } else {
              activeBranches[parentLane] = parent;
            }
          }
          
          routes.add(GraphRoute(fromLane: laneIndex, toLane: parentLane, commitSha: parent));
        }
      }

      // Record routes that pass through this row without interacting
      for (int l = 0; l < activeBranches.length; l++) {
        if (activeBranches[l] != null && l != laneIndex && activeBranches[l] != sha) {
           // We don't add these to routes of *this* commit to avoid duplicating data. 
           // The UI can extrapolate continuous lanes.
        }
      }

      // Compact active branches: remove trailing nulls
      while (activeBranches.isNotEmpty && activeBranches.last == null) {
        activeBranches.removeLast();
      }

      result.add(GraphCommitEntity(
        sha: sha,
        parents: parents,
        author: author,
        authorEmail: authorEmail,
        date: DateTime.parse(dateStr),
        message: message,
        refs: refs,
        lane: laneIndex,
        routes: routes,
      ));
    }

    return result;
  }
}
