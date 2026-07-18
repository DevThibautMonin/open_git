import "package:flutter/material.dart";
import "package:open_git/features/working_directory/presentation/ui/stash_item.dart";
import "package:open_git/shared/domain/entities/git_stash_entity.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_section_header.dart";

class StashesSection extends StatelessWidget {
  final List<GitStashEntity> stashes;

  const StashesSection({
    super.key,
    required this.stashes,
  });

  @override
  Widget build(BuildContext context) {
    if (stashes.isEmpty) {
      return const SizedBox.shrink();
    }

    return DesktopPanel(
      bottomBorder: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: Column(
          children: [
            DesktopSectionHeader(
              title: "Stashes",
              count: stashes.length.toString(),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stashes.length,
                itemBuilder: (context, index) {
                  return StashItem(stash: stashes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
