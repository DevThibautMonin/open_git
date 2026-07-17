import "package:flutter/material.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";

class ImagePreviewCanvas extends StatelessWidget {
  final Widget child;

  const ImagePreviewCanvas({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).openGit.appBackground,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 48
              ? constraints.maxWidth - 48
              : 0.0;
          final height = constraints.maxHeight > 48
              ? constraints.maxHeight - 48
              : 0.0;

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
