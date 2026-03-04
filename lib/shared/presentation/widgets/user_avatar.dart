import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String authorName;
  final String authorEmail;
  final double size;

  const UserAvatar({
    super.key,
    required this.authorName,
    required this.authorEmail,
    this.size = 24.0,
  });

  String get _avatarUrl {
    final cleanEmail = authorEmail.trim().toLowerCase();
    return 'https://avatars.githubusercontent.com/u/e?email=${Uri.encodeComponent(cleanEmail)}';
  }

  String get _initials {
    if (authorName.isEmpty) return "?";
    final parts = authorName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      if (parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return "?";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: theme.colorScheme.primaryContainer,
        child: Image.network(
          _avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                _initials,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: size * 0.4,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
