import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';
import 'package:open_git/shared/presentation/themes/open_git_theme_extension.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart';
import 'package:open_git/shared/presentation/widgets/desktop/desktop_segmented_control.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class FileDifferencesHeader extends StatelessWidget {
  final String? filePath;
  final DiffModeDisplay mode;

  const FileDifferencesHeader({
    super.key,
    required this.mode,
    this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopPanel(
      color: theme.openGit.toolbar,
      bottomBorder: true,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          FileTypeIcon(
            type: filePath?.fileType ?? FileTypeEnum.unknown,
          ),
          Gaps.w8,
          Expanded(
            child: Text(
              filePath ?? 'No file selected',
              style: theme.openGitBody.copyWith(
                fontWeight: FontWeight.w700,
                color: filePath == null
                    ? theme.openGit.textMuted
                    : theme.openGit.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          DesktopSegmentedControl<DiffModeDisplay>(
            selected: mode,
            segments: const [
              DesktopSegment(
                value: DiffModeDisplay.unified,
                label: 'Unified',
                icon: Icons.view_agenda,
              ),
              DesktopSegment(
                value: DiffModeDisplay.split,
                label: 'Split',
                icon: Icons.view_column,
              ),
            ],
            onChanged: (selection) {
              context.read<FilesDifferencesBloc>().add(
                SetDiffModeDisplay(selection),
              );
            },
          ),
        ],
      ),
    );
  }
}
