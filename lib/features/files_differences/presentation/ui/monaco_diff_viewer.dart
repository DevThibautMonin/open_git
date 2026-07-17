import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_monaco/flutter_monaco.dart";
import "package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart";
import "package:open_git/features/files_differences/presentation/extensions/diff_syntax_language_extension.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class MonacoDiffViewer extends StatelessWidget {
  final bool renderSideBySide;

  const MonacoDiffViewer({
    super.key,
    required this.renderSideBySide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
      builder: (context, state) {
        if (state.status == FilesDifferencesStatus.loading) {
          return const Center(
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state.diff.isEmpty &&
            state.originalContent == state.modifiedContent) {
          return const DesktopEmptyState(
            icon: Icons.check_circle_outline,
            title: "No changes",
          );
        }

        return ColoredBox(
          color: theme.openGit.appBackground,
          child: MonacoDiffEditor(
            original: state.originalContent,
            modified: state.modifiedContent,
            language: state.selectedFilePath.diffSyntaxLanguage,
            backgroundColor: theme.openGit.appBackground,
            options: const EditorOptions(
              fontSize: 13,
              fontFamily: "Menlo, Monaco, Courier New, monospace",
              minimap: MonacoMinimapOptions(enabled: false),
              automaticLayout: true,
              readOnly: true,
              scrollBeyondLastLine: false,
              renderLineHighlight: MonacoLineHighlight.none,
              folding: true,
              contextMenu: true,
            ),
            diffOptions: MonacoDiffOptions(
              renderSideBySide: renderSideBySide,
              readOnly: true,
              originalEditable: false,
              ignoreTrimWhitespace: false,
              renderMarginRevertIcon: false,
            ),
            loadingBuilder: (context) {
              return const Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return DesktopEmptyState(
                icon: Icons.error_outline,
                title: "Diff preview unavailable",
                message: error.toString(),
              );
            },
          ),
        );
      },
    );
  }
}
