abstract class DeleteProjectState {}

class DeleteProjectInitial extends DeleteProjectState {}

class DeleteProjectLoading extends DeleteProjectState {}

class DeleteProjectSuccess extends DeleteProjectState {}

class DeleteProjectError extends DeleteProjectState {
  final String message;
  DeleteProjectError(this.message);
}
