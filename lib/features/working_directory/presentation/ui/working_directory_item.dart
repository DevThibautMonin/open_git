import 'package:flutter/material.dart';
import 'package:open_git/shared/domain/entities/git_file_entity.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class WorkingDirectoryItem extends StatelessWidget {
  final GitFileEntity file;
  final Function(GitFileEntity file) onSelected;
  final ValueChanged<bool?> onCheckboxToggled;

  const WorkingDirectoryItem({
    super.key,
    required this.file,
    required this.onSelected,
    required this.onCheckboxToggled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(file);
      },
      child: Row(
        children: [
          Checkbox(
            value: file.selected,
            onChanged: onCheckboxToggled,
          ),
          Icon(
            file.status.icon,
            size: 16,
            color: file.status.color,
          ),
          Gaps.w4,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
