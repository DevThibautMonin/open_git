import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/new_branch_dialog.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/home/presentation/bloc/home_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/clone_repository_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/git_https_remote_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/ssh_host_verification_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/ssh_permission_denied_dialog.dart';
import 'package:open_git/shared/core/constants/constants.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/presentation/widgets/repository_header.dart';
import 'package:open_git/shared/presentation/widgets/repository_sidebar.dart';
import 'package:open_git/shared/presentation/widgets/snackbars/error_snackbar.dart';
import 'package:open_git/shared/presentation/widgets/snackbars/success_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkingDirectoryBloc _workingDirectoryBloc = getIt();
  final HomeBloc _homeBloc = getIt();
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
          create: (context) => _homeBloc..add(InitLastRepository()),
        ),
        BlocProvider(
          create: (context) => getIt<BranchesBloc>(),
        ),
        BlocProvider(
          create: (context) => _workingDirectoryBloc..add(GetRepositoryStatus()),
        ),
        BlocProvider(
          create: (context) => getIt<CommitHistoryBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WorkingDirectoryBloc, WorkingDirectoryState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              switch (state.status) {
                case WorkingDirectoryBlocStatus.commitsPushed:
                  context.read<CommitHistoryBloc>().add(LoadCommitHistory());
                  _workingDirectoryBloc.add(
                    UpdateWorkingDirectoryStatus(
                      status: WorkingDirectoryBlocStatus.initial,
                    ),
                  );
                  break;
                case WorkingDirectoryBlocStatus.gitRemoteIsHttps:
                  final sshCommand = state.gitRemoteCommand;

                  await showDialog(
                    context: context,
                    builder: (_) {
                      return GitHttpsRemoteDialog(
                        sshCommand: sshCommand,
                      );
                    },
                  );

                  _workingDirectoryBloc.add(
                    UpdateWorkingDirectoryStatus(
                      status: WorkingDirectoryBlocStatus.initial,
                    ),
                  );
                  break;
                case WorkingDirectoryBlocStatus.gitSshPermissionDenied:
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return const SshPermissionDeniedDialog();
                    },
                  );
                  _workingDirectoryBloc.add(
                    UpdateWorkingDirectoryStatus(
                      status: WorkingDirectoryBlocStatus.initial,
                    ),
                  );
                  break;

                case WorkingDirectoryBlocStatus.gitSshHostVerificationFailed:
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return const SshHostVerificationDialog();
                    },
                  );

                  _workingDirectoryBloc.add(
                    UpdateWorkingDirectoryStatus(
                      status: WorkingDirectoryBlocStatus.initial,
                    ),
                  );
                  break;
                case WorkingDirectoryBlocStatus.error:
                  ErrorSnackBar.show(
                    context,
                    message: state.errorMessage,
                    duration: Constants.snackbarErrorDuration,
                  );
                  _workingDirectoryBloc.add(UpdateWorkingDirectoryStatus(status: WorkingDirectoryBlocStatus.initial));
                  break;
                default:
              }
            },
          ),
          BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              switch (state.status) {
                case HomeBlocStatus.error:
                  ErrorSnackBar.show(
                    context,
                    message: state.errorMessage,
                    duration: Constants.snackbarErrorDuration,
                  );
                  break;

                case HomeBlocStatus.cloneSuccess:
                  Navigator.pop(context);
                  SuccessSnackBar.show(
                    context,
                    message: 'Repository cloned successfully',
                  );
                  _homeBloc.add(UpdateHomeStatus(status: HomeBlocStatus.initial));
                  break;

                case HomeBlocStatus.askForCloningRepository:
                  final homeBloc = context.read<HomeBloc>();

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return BlocProvider.value(
                        value: homeBloc,
                        child: CloneRepositoryDialog(),
                      );
                    },
                  );
                  break;

                case HomeBlocStatus.repositorySelected:
                  context.read<BranchesBloc>().add(GetRepositoryBranches());
                  _workingDirectoryBloc.add(GetRepositoryStatus());
                  context.read<CommitHistoryBloc>().add(LoadCommitHistory());
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
                  _homeBloc.add(UpdateHomeStatus(status: HomeBlocStatus.initial));
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
                case BranchesBlocStatus.error:
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        behavior: SnackBarBehavior.floating,
                        duration: Constants.snackbarErrorDuration,
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
                    return BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
                      builder: (context, wdState) {
                        return RepositoryHeader(
                          repositoryName: state.currentRepositoryName,
                          onSelectRepository: () {
                            _homeBloc.add(SelectRepository());
                          },
                          onCloneRepository: () {
                            _homeBloc.add(UpdateHomeStatus(status: HomeBlocStatus.askForCloningRepository));
                          },
                          commitsToPush: wdState.commitsToPush,
                          onPush: () {
                            _workingDirectoryBloc.add(PushCommits());
                          },
                          isLoading: wdState.status == WorkingDirectoryBlocStatus.loading,
                        );
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
                                onFileSelected: (file) {
                                  print(file.path);
                                },
                                hasStagedFiles: workingDirectoryState.files.any((file) => file.staged),
                                onCommitPressed: ({required description, required summary}) {
                                  _workingDirectoryBloc.add(AddCommit(summary: summary, description: description));
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
