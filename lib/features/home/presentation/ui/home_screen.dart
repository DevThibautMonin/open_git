import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/new_branch_dialog.dart';
import 'package:open_git/features/home/presentation/bloc/home_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/presentation/widgets/repository_header.dart';
import 'package:open_git/shared/presentation/widgets/repository_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkingDirectoryBloc _workingDirectoryBloc = getIt();
  late AppLifecycleState? state;
  late final AppLifecycleListener listener;

  @override
  void initState() {
    super.initState();
    state = SchedulerBinding.instance.lifecycleState;
    listener = AppLifecycleListener(
      onResume: () => _workingDirectoryBloc.add(GetRepositoryStatus()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<HomeBloc>()..add(InitLastRepository()),
        ),
        BlocProvider(
          create: (context) => getIt<BranchesBloc>(),
        ),
        BlocProvider(
          create: (context) => _workingDirectoryBloc..add(GetRepositoryStatus()),
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
                  _workingDirectoryBloc.add(GetRepositoryStatus());
                  break;
                default:
              }
            },
          ),
          BlocListener<BranchesBloc, BranchesState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              switch (state.status) {
                case BranchesBlocStatus.branchesRetrieved:
                  context.read<HomeBloc>().add(UpdateHomeStatus(status: HomeBlocStatus.initial));
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
                case BranchesBlocStatus.error:
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
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
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
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

                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));

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
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return RepositoryHeader(
                      repositoryName: state.currentRepositoryName,
                      onSelectRepository: () {
                        context.read<HomeBloc>().add(SelectRepository());
                      },
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
                    builder: (context, workingDirectoryState) {
                      return BlocBuilder<BranchesBloc, BranchesState>(
                        builder: (context, branchState) {
                          return Row(
                            children: [
                              RepositorySidebar(
                                branches: branchState.branches,
                                files: workingDirectoryState.files,
                                onNewBranch: () {
                                  context.read<BranchesBloc>().add(
                                    UpdateBranchesStatus(
                                      status: BranchesBlocStatus.createNewBranchAndCheckout,
                                    ),
                                  );
                                },
                                onCheckboxToggled: (file) {
                                  // TODO : Add file staging
                                },
                                onFileSelected: (file) {
                                  print(file.path);
                                },
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Diff / Commit view",
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
