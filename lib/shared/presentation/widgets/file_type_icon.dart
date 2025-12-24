import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';

class FileTypeIcon extends StatelessWidget {
  final FileTypeEnum type;
  final double size;

  const FileTypeIcon({
    super.key,
    required this.type,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      type.assetPath,
      width: size,
      height: size,
    );
  }
}
