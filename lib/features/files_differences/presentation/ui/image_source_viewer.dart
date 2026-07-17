import "package:flutter/material.dart";
import "package:open_git/shared/presentation/widgets/code_block.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class ImageSourceViewer extends StatelessWidget {
  final String? source;

  const ImageSourceViewer({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.isEmpty) {
      return const DesktopEmptyState(
        icon: Icons.code_off_outlined,
        title: "Source unavailable",
        message: "The selected image does not expose readable source content.",
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: CodeBlock(source!),
    );
  }
}
