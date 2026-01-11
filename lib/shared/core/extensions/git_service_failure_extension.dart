import 'package:open_git/shared/domain/failures/git_service_failure.dart';

extension GitServiceFailureExtension on GitServiceFailure {
  String get errorMessage {
    return switch (this) {
      RepositoryDoesntExistsFailure() => "No repository is currently selected.",
      RepositoryNotSelectedFailure() => "Please select a repository to continue.",
      RepositoryPathInvalidFailure() =>
        "The repository folder no longer exists or is inaccessible. "
            "Please select or clone the repository again.",
      DirectoryNotEmptyFailure() =>
        "The selected folder is not empty. "
            "Please choose an empty directory to clone the repository.",
      GitNotFoundFailure() =>
        "Git is not installed or not available in your system PATH. "
            "Please install Git and restart the application.",
      GitSshHostVerificationFailure() =>
        "The SSH host could not be verified. "
            "Please run 'ssh -T git@host' in a terminal to trust the host.",
      GitSshPermissionDeniedFailure() =>
        "SSH authentication failed. "
            "Please make sure your SSH key is added to your Git provider.",
      GitHttpsAuthRequiredFailure() =>
        "Authentication is required to access this repository. "
            "Please check your HTTPS credentials or switch to SSH.",
      GitCloneFailure() =>
        "Failed to clone the repository. "
            "Please check your network connection and repository access.",
      GitProcessFailure() =>
        "A system error occurred while running a Git command. "
            "Please try again or restart the application.",
      GitServiceUnknownFailure() =>
        "An unexpected Git error occurred. "
            "Command: $command\n"
            "Details: $stdErr",
    };
  }
}
