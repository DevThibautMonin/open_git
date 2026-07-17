import "dart:typed_data";

import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class RasterImagePreview extends StatelessWidget {
  final Uint8List bytes;

  const RasterImagePreview({
    super.key,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const DesktopEmptyState(
          icon: Icons.broken_image_outlined,
          title: "Preview failed",
          message: "The image could not be decoded.",
        );
      },
    );
  }
}
