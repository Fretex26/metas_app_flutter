abstract class CreateTaskState {}

class CreateTaskInitial extends CreateTaskState {}

class CreateTaskLoading extends CreateTaskState {}

class CreateTaskSuccess extends CreateTaskState {
  final String taskId;

  CreateTaskSuccess(this.taskId);
}

class CreateTaskError extends CreateTaskState {
  final String message;

  CreateTaskError(this.message);
}
