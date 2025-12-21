import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/home/presentation/bloc/home_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/branches_list.dart';
import 'package:open_git/shared/core/di/injectable.dart';
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
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case HomeBlocStatus.repositorySelected:
              context.read<BranchesBloc>().add(GetRepositoryBranches());
              break;
            default:
          }
        },
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
                    return BranchesList(
                      branches: state.branches,
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
