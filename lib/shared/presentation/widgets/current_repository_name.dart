import 'package:flutter/material.dart';

class CurrentRepositoryName extends StatelessWidget {
  final String repositoryName;

  const CurrentRepositoryName({
    super.key,
    required this.repositoryName,
  });

  @override
  Widget build(BuildContext context) {
    return repositoryName.isNotEmpty
        ? Column(
            children: [
              Text("Repository"),
              Text(repositoryName),
            ],
          )
        : Text("No repository selected");
  }
}
