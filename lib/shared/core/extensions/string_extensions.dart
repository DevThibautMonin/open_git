import 'package:flutter/foundation.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';

extension FileTypeEnumResolver on String {
  FileTypeEnum get fileType {
    final lower = toLowerCase();

    switch (lower) {
      case 'jenkinsfile':
        return FileTypeEnum.jenkins;
    }

    if (lower.endsWith('.blade.php')) {
      return FileTypeEnum.laravel;
    }

    if (!lower.contains('.')) {
      _log('NO EXTENSION');
      return FileTypeEnum.unknown;
    }

    final ext = lower.split('.').last;

    switch (ext) {
      case 'dart':
        return FileTypeEnum.dart;
      case 'swift':
        return FileTypeEnum.swift;
      case 'kt':
        return FileTypeEnum.kotlin;
      case 'php':
        return FileTypeEnum.php;
      case 'gitignore':
        return FileTypeEnum.git;
      case 'js':
        return FileTypeEnum.javascript;
      case 'Jenkinsfile':
        return FileTypeEnum.jenkins;
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
