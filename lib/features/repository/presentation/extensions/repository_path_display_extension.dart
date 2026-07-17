import "package:path/path.dart" as p;

extension RepositoryPathDisplayExtension on String {
  String get repositoryDisplayName {
    if (isEmpty) return "";
    return p.basename(this);
  }

  String get repositoryParentPath {
    if (isEmpty) return "";
    return p.dirname(this);
  }
}
