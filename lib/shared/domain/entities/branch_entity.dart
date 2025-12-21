import 'package:dart_mappable/dart_mappable.dart';

part 'branch_entity.mapper.dart';

@MappableClass()
class BranchEntity with BranchEntityMappable {
  final String name;
  final bool isCurrent;

  const BranchEntity({
    required this.isCurrent,
    required this.name,
  });
}
