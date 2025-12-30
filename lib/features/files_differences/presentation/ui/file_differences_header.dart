import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class FileDifferencesHeader extends StatelessWidget {
  final GitFileEntity? file;
  final DiffModeDisplay mode;

  const FileDifferencesHeader({
    super.key,
    required this.file,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          FileTypeIcon(
            type: file?.path.fileType ?? FileTypeEnum.unknown,
          ),
          Gaps.w8,
          Expanded(
            child: Text(
              file?.path ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SegmentedButton<DiffModeDisplay>(
            segments: const [
              ButtonSegment(
                value: DiffModeDisplay.unified,
                label: Text('Unified'),
                icon: Icon(Icons.view_agenda),
              ),
              ButtonSegment(
                value: DiffModeDisplay.split,
                label: Text('Split'),
                icon: Icon(Icons.view_column),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              context.read<FilesDifferencesBloc>().add(SetDiffModeDisplay(selection.first));
            },
          ),
        ],
      ),
    );
  }
}
