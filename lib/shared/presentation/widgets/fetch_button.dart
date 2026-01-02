import 'package:flutter/material.dart';

class FetchButton extends StatelessWidget {
  final VoidCallback onFetch;
  final bool isLoading;

  const FetchButton({
    super.key,
    required this.onFetch,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onFetch,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      label: Text(isLoading ? "Fetching..." : "Fetch"),
    );
  }
}
