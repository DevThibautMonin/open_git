import 'package:flutter/material.dart';
import 'package:open_git/features/files_differences/domain/entities/diff_hunk_entity.dart';
import 'package:open_git/features/files_differences/presentation/ui/diff_hunk_widget.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/domain/enums/file_type_enum.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class DiffViewer extends StatelessWidget {
  final List<DiffHunkEntity> hunks;
  final GitFileEntity? file;

  const DiffViewer({
    super.key,
    required this.hunks,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    if (hunks.isEmpty) {
      return const Center(child: Text('No changes'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              FileTypeIcon(
                type: file?.path.fileType ?? FileTypeEnum.unknown,
              ),
              Gaps.w8,
              Text(
                file?.path ?? "",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: hunks.length,
            itemBuilder: (_, i) {
              return DiffHunkWidget(
                hunk: hunks[i],
              );
            },
          ),
        ),
      ],
    );
  }
}
