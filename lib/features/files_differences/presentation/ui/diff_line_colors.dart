import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_line_type.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';

extension DiffLineTypeThemeColors on DiffLineType {
  Color themedBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);

    return switch (this) {
      DiffLineType.added => theme.openGit.codeAdded,
      DiffLineType.removed => theme.openGit.codeRemoved,
      DiffLineType.unchanged => Colors.transparent,
    };
  }

  Color themedForegroundColor(BuildContext context) {
    final theme = Theme.of(context);

    return switch (this) {
      DiffLineType.added => theme.openGit.success,
      DiffLineType.removed => theme.openGit.danger,
      DiffLineType.unchanged => Colors.transparent,
    };
  }
}
