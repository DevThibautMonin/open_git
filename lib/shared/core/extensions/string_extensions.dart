import 'package:flutter/foundation.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';

extension FileTypeEnumResolver on String {
  FileTypeEnum get fileType {
    if (!contains('.')) {
      _log('NO EXTENSION');
      return FileTypeEnum.unknown;
    }

    final ext = split('.').last.toLowerCase();

    switch (ext) {
      case 'dart':
        return FileTypeEnum.dart;
      case 'js':
        return FileTypeEnum.javascript;
      case 'ts':
        return FileTypeEnum.typescript;
      case 'md':
        return FileTypeEnum.markdown;
      case 'json':
        return FileTypeEnum.json;
      case 'yaml':
      case 'yml':
        return FileTypeEnum.yaml;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
      case 'gif':
      case 'svg':
        return FileTypeEnum.image;
      default:
        _log('UNKNOWN EXTENSION: .$ext');
        return FileTypeEnum.unknown;
    }
  }

  void _log(String reason) {
    if (kDebugMode) {
      debugPrint(
        '[FileTypeEnumResolver] $reason\n'
        '  path: $this',
      );
    }
  }
}
