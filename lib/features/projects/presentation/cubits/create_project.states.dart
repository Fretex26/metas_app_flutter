abstract class CreateProjectState {}

class CreateProjectInitial extends CreateProjectState {}

class CreateProjectLoading extends CreateProjectState {}

class CreateProjectSuccess extends CreateProjectState {
  final String projectId;

  CreateProjectSuccess(this.projectId);
}

class CreateProjectError extends CreateProjectState {
  final String message;

  CreateProjectError(this.message);
}
