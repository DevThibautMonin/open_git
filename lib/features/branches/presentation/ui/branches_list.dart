import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branch_item.dart';
import 'package:open_git/shared/domain/entities/branch_entity.dart';

class BranchesList extends StatelessWidget {
  final List<BranchEntity> branches;

  const BranchesList({
    super.key,
    this.branches = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Column(
        children: [
          Text("Branches"),
          SizedBox(
            height: 100,
            width: 100,
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];

                return BranchItem(
                  onTap: () {
                    context.read<BranchesBloc>().add(SwitchToBranch(branch: branch));
                  },
                  branch: branch,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
