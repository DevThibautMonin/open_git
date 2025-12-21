import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/new_branch_dialog.dart';
import 'package:open_git/features/home/presentation/bloc/home_bloc.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/features/branches/presentation/ui/branches_sidebar.dart';
import 'package:open_git/shared/presentation/widgets/current_repository_name.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<HomeBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<BranchesBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              switch (state.status) {
                case HomeBlocStatus.repositorySelected:
                  context.read<BranchesBloc>().add(GetRepositoryBranches());
                  break;
                default:
              }
            },
          ),
          BlocListener<BranchesBloc, BranchesState>(
            listener: (context, state) async {
              switch (state.status) {
                case BranchesBlocStatus.branchCreated:
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("Branch created successfully !"),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  context.read<BranchesBloc>().add(UpdateStatus(status: BranchesBlocStatus.initial));
                  break;
                case BranchesBlocStatus.createNewBranchAndCheckout:
                  final name = await showDialog<String>(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) {
                      return const NewBranchDialog();
                    },
                  );

                  if (!context.mounted) return;

                  context.read<BranchesBloc>().add(UpdateStatus(status: BranchesBlocStatus.initial));

                  if (name != null && name.isNotEmpty) {
                    context.read<BranchesBloc>().add(
                      CreateNewBranchAndCheckout(branchName: name),
                    );
                  }
                  break;
                default:
              }
            },
          ),
        ],
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    return OutlinedButton(
                      onPressed: () async {
                        context.read<HomeBloc>().add(SelectRepository());
                      },
                      child: Text("Open repository"),
                    );
                  },
                ),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) => previous.currentRepositoryName != current.currentRepositoryName,
                  builder: (context, state) {
                    return CurrentRepositoryName(
                      repositoryName: state.currentRepositoryName,
                    );
                  },
                ),
                Divider(),
                BlocBuilder<BranchesBloc, BranchesState>(
                  buildWhen: (previous, current) => previous.branches != current.branches,
                  builder: (context, state) {
                    return Expanded(
                      child: BranchesSidebar(
                        branches: state.branches,
                        onNewBranch: () {
                          context.read<BranchesBloc>().add(UpdateStatus(status: BranchesBlocStatus.createNewBranchAndCheckout));
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
