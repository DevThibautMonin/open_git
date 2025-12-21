part of 'working_directory_bloc.dart';

sealed class WorkingDirectoryEvent {}

class GetRepositoryStatus extends WorkingDirectoryEvent {
  GetRepositoryStatus();
}
