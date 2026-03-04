import 'package:dart_mappable/dart_mappable.dart';

part 'graph_route.mapper.dart';

@MappableClass()
class GraphRoute with GraphRouteMappable {
  final int fromLane;
  final int toLane;
  final String commitSha;

  const GraphRoute({
    required this.fromLane,
    required this.toLane,
    required this.commitSha,
  });
}
