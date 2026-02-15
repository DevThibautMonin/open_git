import 'package:flutter/material.dart';
import 'package:open_git/features/branches/presentation/ui/branch_group.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/core/services/ui_preferences_service.dart';
import 'package:open_git/shared/domain/entities/branch_group_entity.dart';
import 'package:open_git/shared/presentation/widgets/gaps.dart';

class RemoteBranchesSection extends StatefulWidget {
  final List<BranchGroupEntity> branchGroups;

  const RemoteBranchesSection({
    super.key,
    required this.branchGroups,
  });

  @override
  State<RemoteBranchesSection> createState() => _RemoteBranchesSectionState();
}

class _RemoteBranchesSectionState extends State<RemoteBranchesSection> {
  final UiPreferencesService _prefsService = getIt();
  Map<String, bool> _expansionState = {};

  @override
  void initState() {
    super.initState();
    _loadExpansionState();
  }

  void _loadExpansionState() {
    setState(() {
      _expansionState = _prefsService.getBranchGroupsExpansionState();
    });
  }

  bool _isGroupExpanded(String prefix) {
    final key = 'remote:$prefix';
    return _expansionState[key] ?? false;
  }

  Future<void> _toggleGroup(String prefix) async {
    final key = 'remote:$prefix';
    setState(() {
      _expansionState[key] = !(_expansionState[key] ?? false);
    });
    await _prefsService.setBranchGroupsExpansionState(_expansionState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.branchGroups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.h8,
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "Remote branches",
            style: theme.textTheme.labelMedium,
          ),
        ),
        ...widget.branchGroups.map((group) {
          return BranchGroup(
            group: group,
            isExpanded: _isGroupExpanded(group.prefix),
            onToggle: () => _toggleGroup(group.prefix),
          );
        }),
      ],
    );
  }
}
