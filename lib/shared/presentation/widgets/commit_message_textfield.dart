import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/working_directory/presentation/bloc/working_directory_bloc.dart";
import "package:open_git/shared/presentation/themes/open_git_theme_extension.dart";
import "package:open_git/shared/presentation/widgets/commit_button.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_checkbox.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart";
import "package:open_git/shared/presentation/widgets/gaps.dart";

class CommitMessageTextfield extends StatefulWidget {
  final bool hasStagedFiles;

  const CommitMessageTextfield({
    super.key,
    required this.hasStagedFiles,
  });

  @override
  State<CommitMessageTextfield> createState() => CommitMessageTextfieldState();
}

class CommitMessageTextfieldState extends State<CommitMessageTextfield> {
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    summaryController.addListener(onSummaryChanged);
    descriptionController.addListener(onDescriptionChanged);
  }

  @override
  void dispose() {
    summaryController.removeListener(onSummaryChanged);
    descriptionController.removeListener(onDescriptionChanged);
    summaryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void onSummaryChanged() {
    context.read<WorkingDirectoryBloc>().add(
      UpdateCommitSummary(summary: summaryController.text),
    );
  }

  void onDescriptionChanged() {
    context.read<WorkingDirectoryBloc>().add(
      UpdateCommitDescription(description: descriptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<WorkingDirectoryBloc, WorkingDirectoryState>(
      listenWhen: (previous, current) {
        return previous.commitSummary != current.commitSummary ||
            previous.commitDescription != current.commitDescription;
      },
      listener: (context, state) {
        if (summaryController.text != state.commitSummary) {
          summaryController.text = state.commitSummary;
        }

        if (descriptionController.text != state.commitDescription) {
          descriptionController.text = state.commitDescription;
        }
      },
      builder: (context, state) {
        final summary = state.commitSummary.trim();
        final description = state.commitDescription.trim();
        final isAmending = state.amendLatestCommit;
        final isCommitEnabled = widget.hasStagedFiles && summary.isNotEmpty;
        final isAmendEnabled = summary.isNotEmpty;
        final isEnabled = isAmending ? isAmendEnabled : isCommitEnabled;
        final buttonText = isAmending
            ? "Amend commit"
            : widget.hasStagedFiles
            ? "Commit"
            : "No staged files";

        return DesktopPanel(
          topBorder: true,
          color: theme.openGit.toolbar,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Commit",
                style: theme.openGitSectionLabel,
              ),
              Gaps.h8,
              DesktopTextField(
                controller: summaryController,
                maxLength: 50,
                labelText: "Summary",
                hintText: "Short summary of the commit",
              ),
              const SizedBox(height: 8),
              DesktopTextField(
                controller: descriptionController,
                labelText: "Description",
                hintText: "More detailed explanation...",
                maxLines: 4,
              ),
              Gaps.h8,
              Row(
                children: [
                  DesktopCheckbox(
                    value: isAmending,
                    tooltip: "Amend latest commit",
                    onChanged: (checked) {
                      context.read<WorkingDirectoryBloc>().add(
                        ToggleAmendLatestCommit(amend: checked),
                      );
                    },
                  ),
                  Gaps.w8,
                  Expanded(
                    child: Text(
                      "Amend latest commit",
                      overflow: TextOverflow.ellipsis,
                      style: theme.openGitCaption,
                    ),
                  ),
                ],
              ),
              Gaps.h8,
              CommitButton(
                text: buttonText,
                onPressed: () {
                  if (isAmending) {
                    context.read<WorkingDirectoryBloc>().add(
                      AmendCommit(
                        summary: summary,
                        description: description,
                      ),
                    );
                    return;
                  }

                  context.read<WorkingDirectoryBloc>().add(
                    AddCommit(
                      summary: summary,
                      description: description,
                    ),
                  );
                },
                isEnabled: isEnabled,
              ),
            ],
          ),
        );
      },
    );
  }
}
