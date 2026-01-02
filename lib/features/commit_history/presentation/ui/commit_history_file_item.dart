import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/core/extensions/string_extensions.dart';
import 'package:open_git/shared/presentation/widgets/file_type_icon.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class CommitHistoryFileItem extends StatelessWidget {
  final String filePath;
  final VoidCallback onTap;

  const CommitHistoryFileItem({
    super.key,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
      builder: (context, state) {
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                FileTypeIcon(type: filePath.fileType),
                Gaps.w8,
                Expanded(
                  child: Text(
                    filePath,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
