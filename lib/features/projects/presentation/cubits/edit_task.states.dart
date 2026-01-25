import 'package:metas_app/features/projects/domain/entities/task.dart';

abstract class EditTaskState {}

class EditTaskInitial extends EditTaskState {}

class EditTaskLoading extends EditTaskState {}

class EditTaskSuccess extends EditTaskState {
  final Task task;
  EditTaskSuccess(this.task);
}

class EditTaskError extends EditTaskState {
  final String message;
  EditTaskError(this.message);
}
