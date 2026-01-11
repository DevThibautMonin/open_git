import 'package:dart_mappable/dart_mappable.dart';

part 'branch_entity.mapper.dart';

@MappableClass()
class BranchEntity with BranchEntityMappable {
  final String name;
  final bool isCurrent;
  final bool isRemote;
  final bool existsLocally;
  final bool deletedOnRemote;

  const BranchEntity({
    required this.isCurrent,
    required this.name,
    required this.isRemote,
    required this.existsLocally,
    this.deletedOnRemote = false,
  });
}
