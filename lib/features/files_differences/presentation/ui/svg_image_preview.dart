import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class SvgImagePreview extends StatelessWidget {
  final Uint8List bytes;

  const SvgImagePreview({
    super.key,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.memory(
      bytes,
      fit: BoxFit.contain,
      placeholderBuilder: (context) {
        return const Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
