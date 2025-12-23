sealed class GitException implements Exception {
  const GitException();
}

class GitCommandFailed extends GitException {
  final String command;
  final String stderr;

  const GitCommandFailed({
    required this.command,
    required this.stderr,
  });
}

/// SSH / Auth
class GitSshHostVerificationFailed extends GitException {}

class GitSshPermissionDenied extends GitException {}

class GitHttpsAuthRequired extends GitException {}

/// Fallback
class GitUnknownException extends GitException {
  final String message;
  const GitUnknownException(this.message);
}
