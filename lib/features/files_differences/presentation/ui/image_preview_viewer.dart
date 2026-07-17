import "dart:typed_data";

import "package:flutter/material.dart";
import "package:open_git/features/files_differences/presentation/extensions/svg_source_preview_extension.dart";
import "package:open_git/features/files_differences/presentation/ui/embedded_raster_image_preview.dart";
import "package:open_git/features/files_differences/presentation/ui/image_preview_canvas.dart";
import "package:open_git/features/files_differences/presentation/ui/raster_image_preview.dart";
import "package:open_git/features/files_differences/presentation/ui/svg_image_preview.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class ImagePreviewViewer extends StatelessWidget {
  final List<int>? bytes;
  final String filePath;
  final String? source;
  final String previewErrorMessage;

  const ImagePreviewViewer({
    super.key,
    required this.bytes,
    required this.filePath,
    required this.source,
    required this.previewErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = this.bytes;

    if (bytes == null) {
      return DesktopEmptyState(
        icon: Icons.image_not_supported_outlined,
        title: "Preview unavailable",
        message: previewErrorMessage.isEmpty
            ? "The selected file cannot be previewed."
            : previewErrorMessage,
      );
    }

    final data = Uint8List.fromList(bytes);
    final isSvg = filePath.toLowerCase().endsWith(".svg");
    final embeddedImage = isSvg ? source?.embeddedRasterImageBytes : null;
    final preview = embeddedImage != null
        ? EmbeddedRasterImagePreview(bytes: embeddedImage)
        : isSvg
        ? SvgImagePreview(bytes: data)
        : RasterImagePreview(bytes: data);

    return ImagePreviewCanvas(
      child: preview,
    );
  }
}
