import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/branches/presentation/bloc/branches_bloc.dart';
import 'package:open_git/features/branches/presentation/ui/new_branch_dialog.dart';
import 'package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart';
import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';
import 'package:open_git/features/files_differences/presentation/bloc/files_differences_bloc.dart';
import 'package:open_git/features/files_differences/presentation/ui/file_differences_header.dart';
import 'package:open_git/features/files_differences/presentation/ui/split_diff_viewer.dart';
import 'package:open_git/features/repository/presentation/bloc/repository_bloc.dart';
import 'package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/branch_delete_confirmation_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/clone_repository_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/discard_all_changes_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/discard_file_changes_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/git_https_remote_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/ssh_host_verification_dialog.dart';
import 'package:open_git/shared/presentation/widgets/dialogs/ssh_permission_denied_dialog.dart';
import 'package:open_git/shared/core/constants/constants.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/features/files_differences/presentation/ui/unified_diff_viewer.dart';
import 'package:open_git/features/repository/presentation/ui/repository_header.dart';
import 'package:open_git/features/repository/presentation/ui/repository_sidebar.dart';
import 'package:open_git/shared/presentation/widgets/snackbars/error_snackbar.dart';
import 'package:open_git/shared/presentation/widgets/snackbars/success_snackbar.dart';

class RepositoryScreen extends StatefulWidget {
  const RepositoryScreen({super.key});

  @override
  State<RepositoryScreen> createState() => _RepositoryScreenState();
}

class _RepositoryScreenState extends State<RepositoryScreen> {
  final WorkingDirectoryBloc _workingDirectoryBloc = getIt();
  final FilesDifferencesBloc _filesDifferencesBloc = getIt();
  final RepositoryBloc _repositoryBloc = getIt();
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
          create: (context) => _repositoryBloc
            ..add(InitLastRepository())
            ..add(RetrieveAppVersion()),
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
        BlocProvider(
          create: (context) => _filesDifferencesBloc..add(LoadDiffModeDisplay()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WorkingDirectoryBloc, WorkingDirectoryState>(
            listenWhen: (previous, current) => previous.status != current.status || previous.selectedFile != current.selectedFile,
            listener: (context, state) async {
              switch (state.status) {
                case WorkingDirectoryBlocStatus.askForDiscardFileChanges:
                  if (state.selectedFile != null) {
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return DiscardFileChangesDialog(
                          file: state.selectedFile,
                          onCancel: () {
                            _workingDirectoryBloc.add(
                              UpdateWorkingDirectoryStatus(
                                status: WorkingDirectoryBlocStatus.initial,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          onDiscard: () {
                            Navigator.pop(context);
                            _workingDirectoryBloc.add(DiscardFileChanges(file: state.selectedFile));
                          },
                        );
                      },
                    );
                  }
                case WorkingDirectoryBlocStatus.askForDiscardAllChanges:
                  await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) {
                      return DiscardAllChangesDialog(
                        onCancel: () {
                          _workingDirectoryBloc.add(
                            UpdateWorkingDirectoryStatus(
                              status: WorkingDirectoryBlocStatus.initial,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        onDiscard: () {
                          Navigator.pop(context);
                          _workingDirectoryBloc.add(DiscardAllChanges());
                        },
                      );
                    },
                  );
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
                    barrierDismissible: false,
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
          BlocListener<RepositoryBloc, RepositoryState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              switch (state.status) {
                case RepositoryBlocStatus.error:
                  ErrorSnackBar.show(
                    context,
                    message: state.errorMessage,
                    duration: Constants.snackbarErrorDuration,
                  );
                  break;

                case RepositoryBlocStatus.cloneSuccess:
                  Navigator.pop(context);
                  SuccessSnackBar.show(
                    context,
                    message: 'Repository cloned successfully',
                  );
                  _repositoryBloc.add(UpdateRepositoryStatus(status: RepositoryBlocStatus.initial));
                  break;

                case RepositoryBlocStatus.askForCloningRepository:
                  final repositoryBloc = context.read<RepositoryBloc>();

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return BlocProvider.value(
                        value: repositoryBloc,
                        child: CloneRepositoryDialog(),
                      );
                    },
                  );

                  _repositoryBloc.add(UpdateRepositoryStatus(status: RepositoryBlocStatus.initial));
                  break;

                case RepositoryBlocStatus.repositorySelected:
                  context.read<BranchesBloc>().add(GetRepositoryBranches());
                  _workingDirectoryBloc.add(GetRepositoryStatus());
                  context.read<CommitHistoryBloc>().add(LoadCommitHistory());
                  break;
                default:
              }
            },
          ),
          BlocListener<BranchesBloc, BranchesState>(
            listenWhen: (previous, current) => previous.status != current.status || previous.selectedBranch != current.selectedBranch,
            listener: (context, state) async {
              switch (state.status) {
                case BranchesBlocStatus.askForDeletingBranch:
                  if (state.selectedBranch != null) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return BranchDeleteConfirmationDialog(
                          branchName: state.selectedBranch?.name ?? "No branch selected",
                          onDelete: () {
                            context.read<BranchesBloc>().add(DeleteBranch(branch: state.selectedBranch!));
                          },
                        );
                      },
                    );
                  }
                  if (context.mounted) {
                    context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
                  }

                case BranchesBlocStatus.branchesRetrieved:
                  _repositoryBloc.add(UpdateRepositoryStatus(status: RepositoryBlocStatus.initial));
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
                  break;
                case BranchesBlocStatus.error:
                  ErrorSnackBar.show(
                    context,
                    message: state.errorMessage,
                    duration: Constants.snackbarErrorDuration,
                  );
                  context.read<BranchesBloc>().add(UpdateBranchesStatus(status: BranchesBlocStatus.initial));
                  break;
                case BranchesBlocStatus.branchCreated:
                  SuccessSnackBar.show(
                    context,
                    message: 'Branch created successfully !',
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
                BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
                  builder: (context, wdState) {
                    return RepositoryHeader(
                      onSelectRepository: () {
                        _repositoryBloc.add(SelectRepository());
                      },
                      onCloneRepository: () {
                        _repositoryBloc.add(UpdateRepositoryStatus(status: RepositoryBlocStatus.askForCloningRepository));
                      },
                      commitsToPush: wdState.commitsToPush,
                      onPush: () {
                        _workingDirectoryBloc.add(PushCommits());
                      },
                      isLoading: wdState.status == WorkingDirectoryBlocStatus.pushingCommits,
                      hasUpstream: wdState.hasUpstream,
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<WorkingDirectoryBloc, WorkingDirectoryState>(
                    builder: (context, workingDirectoryState) {
                      return Row(
                        children: [
                          RepositorySidebar(
                            files: workingDirectoryState.files,
                            hasStagedFiles: workingDirectoryState.files.any((file) => file.staged),
                            onCommitPressed: ({required description, required summary}) {
                              _workingDirectoryBloc.add(AddCommit(summary: summary, description: description));
                            },
                          ),
                          BlocBuilder<FilesDifferencesBloc, FilesDifferencesState>(
                            builder: (context, state) {
                              if (state.status == FilesDifferencesStatus.loading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return Expanded(
                                child: Column(
                                  children: [
                                    FileDifferencesHeader(
                                      file: workingDirectoryState.selectedFile,
                                      mode: state.diffModeDisplay,
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: state.diffModeDisplay == DiffModeDisplay.split
                                          ? SplitDiffViewer(hunks: state.diff)
                                          : UnifiedDiffViewer(hunks: state.diff),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
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
