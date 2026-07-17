import "dart:convert";
import "dart:typed_data";

extension SvgSourcePreviewExtension on String {
  Uint8List? get embeddedRasterImageBytes {
    final match = RegExp(
      r"""(?:href|xlink:href)=["']data:image/(?:png|jpe?g|webp|gif);base64,([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(this);

    if (match == null) return null;

    try {
      final data = match.group(1)!.replaceAll(RegExp(r"\s"), "");
      return base64Decode(data);
    } on FormatException {
      return null;
    }
  }
}
