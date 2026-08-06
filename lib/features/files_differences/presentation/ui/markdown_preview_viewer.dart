import "package:flutter/material.dart";
import "package:flutter_markdown_plus/flutter_markdown_plus.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_empty_state.dart";

class MarkdownPreviewViewer extends StatelessWidget {
  final String markdown;

  const MarkdownPreviewViewer({
    super.key,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (markdown.isEmpty) {
      return const DesktopEmptyState(
        icon: Icons.article_outlined,
        title: "Preview unavailable",
        message: "The selected Markdown file has no rendered content.",
      );
    }

    return ColoredBox(
      color: theme.openGit.appBackground,
      child: Markdown(
        data: markdown,
        selectable: true,
        padding: const EdgeInsets.all(24),
        styleSheet: MarkdownStyleSheet(
          a: theme.openGitBody.copyWith(
            color: theme.openGit.accent,
            decoration: TextDecoration.underline,
            decorationColor: theme.openGit.accent,
          ),
          p: theme.openGitBody.copyWith(height: 1.5),
          code: theme.openGitMono.copyWith(
            backgroundColor: theme.openGit.panelAlt,
          ),
          h1: theme.openGitTitle.copyWith(fontSize: 24),
          h2: theme.openGitTitle.copyWith(fontSize: 20),
          h3: theme.openGitTitle.copyWith(fontSize: 17),
          h4: theme.openGitTitle.copyWith(fontSize: 15),
          h5: theme.openGitTitle,
          h6: theme.openGitTitle.copyWith(color: theme.openGit.textSecondary),
          blockSpacing: 12,
          listIndent: 24,
          listBullet: theme.openGitBody,
          blockquote: theme.openGitBody.copyWith(
            color: theme.openGit.textSecondary,
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          blockquoteDecoration: BoxDecoration(
            color: theme.openGit.panelAlt,
            border: Border(
              left: BorderSide(
                color: theme.openGit.accent,
                width: 3,
              ),
            ),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(
            color: theme.openGit.panelAlt,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.openGit.border),
          ),
          tableHead: theme.openGitBody.copyWith(fontWeight: FontWeight.w700),
          tableBody: theme.openGitBody,
          tableBorder: TableBorder.all(color: theme.openGit.border),
          tableCellsPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.openGit.border),
            ),
          ),
        ),
      ),
    );
  }
}
