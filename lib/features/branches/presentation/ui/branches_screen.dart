import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/graph/branch_graph_screen.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchesBloc, BranchesState>(
      builder: (context, state) {
        if (state.status == BranchesBlocStatus.loading || state.status == BranchesBlocStatus.fetchingBranches) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.graphCommits.isEmpty) {
          return const Center(child: Text("No branch history graph available."));
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "${state.graphCommits.length} commits",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: BranchGraphScreen(
                    commits: state.graphCommits,
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
