import 'package:dart_mappable/dart_mappable.dart';
import 'package:open_git/shared/domain/entities/graph_route.dart';

part 'graph_commit_entity.mapper.dart';

@MappableClass()
class GraphCommitEntity with GraphCommitEntityMappable {
  final String sha;
  final List<String> parents;
  final String author;
  final String authorEmail;
  final DateTime date;
  final String message;
  final List<String> refs;
  
  // Graph-specific properties
  final int lane;
  final List<GraphRoute> routes;

  const GraphCommitEntity({
    required this.sha,
    required this.parents,
    required this.author,
    required this.authorEmail,
    required this.date,
    required this.message,
    required this.refs,
    required this.lane,
    required this.routes,
  });
}
