import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:open_git/features/commit_history/presentation/bloc/commit_history_bloc.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_panel.dart";
import "package:open_git/shared/presentation/widgets/desktop/desktop_text_field.dart";

class CommitHistorySearchField extends StatefulWidget {
  const CommitHistorySearchField({
    super.key,
  });

  @override
  State<CommitHistorySearchField> createState() =>
      CommitHistorySearchFieldState();
}

class CommitHistorySearchFieldState extends State<CommitHistorySearchField> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.text = context.read<CommitHistoryBloc>().state.searchQuery;
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    context.read<CommitHistoryBloc>().add(
      SearchCommitHistory(query: searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopPanel(
      bottomBorder: true,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: DesktopTextField(
        controller: searchController,
        hintText: "Search commits",
      ),
    );
  }
}
