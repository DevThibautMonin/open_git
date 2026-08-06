import "package:open_git/shared/core/extensions/string_extensions.dart";
import "package:open_git/shared/domain/enums/file_type_enum.dart";

extension MarkdownPreviewExtension on String {
  bool get canPreviewAsMarkdown {
    return fileType == FileTypeEnum.markdown;
  }
}
