import 'package:dart_mappable/dart_mappable.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';

part 'branch_group_entity.mapper.dart';

@MappableClass()
class BranchGroupEntity with BranchGroupEntityMappable {
  final String prefix;
  final List<BranchEntity> branches;
  final int count;

  const BranchGroupEntity({
    required this.prefix,
    required this.branches,
  }) : count = branches.length;

  /// Extracts the prefix from a branch name (text before first '/')
  /// Returns empty string if no '/' is found
  /// Example: "feature/login" -> "feature/"
  /// Example: "main" -> ""
  static String extractPrefix(String branchName) {
    final slashIndex = branchName.indexOf('/');
    return slashIndex > 0 ? branchName.substring(0, slashIndex + 1) : '';
  }
}
