import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';

class BranchItem extends StatelessWidget {
  final VoidCallback? onTap;
  final BranchEntity branch;

  const BranchItem({
    super.key,
    this.onTap,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BranchesBloc>(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                Icons.call_split,
                size: 16,
                color: branch.isCurrent ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
