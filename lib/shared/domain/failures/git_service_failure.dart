import 'package:open_git/shared/domain/failures/failure.dart';

sealed class GitServiceFailure extends Failure {
  final String? command;
  final String? stdErr;

  GitServiceFailure({
    this.command,
    this.stdErr,
  });
}

final class RepositoryDoesntExistsFailure extends GitServiceFailure {
  RepositoryDoesntExistsFailure();
}

final class GitSshHostVerificationFailure extends GitServiceFailure {
  GitSshHostVerificationFailure();
}

final class GitSshPermissionDeniedFailure extends GitServiceFailure {
  GitSshPermissionDeniedFailure();
}

final class GitHttpsAuthRequiredFailure extends GitServiceFailure {
  GitHttpsAuthRequiredFailure();
}

final class DirectoryNotEmptyFailure extends GitServiceFailure {
  DirectoryNotEmptyFailure();
}

final class GitCloneFailure extends GitServiceFailure {
  GitCloneFailure({
    super.command,
    super.stdErr,
  });
}

final class GitServiceUnknownFailure extends GitServiceFailure {
  GitServiceUnknownFailure({
    super.command,
    super.stdErr,
  });
}

final class RepositoryNotSelectedFailure extends GitServiceFailure {
  RepositoryNotSelectedFailure();
}

final class RepositoryPathInvalidFailure extends GitServiceFailure {
  RepositoryPathInvalidFailure({
    super.command,
    super.stdErr,
  });
}

final class GitNotFoundFailure extends GitServiceFailure {
  GitNotFoundFailure();
}

final class GitProcessFailure extends GitServiceFailure {
  GitProcessFailure({
    super.command,
    super.stdErr,
  });
}
