import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';

abstract class TaskDetailState {}

class TaskDetailInitial extends TaskDetailState {}

class TaskDetailLoading extends TaskDetailState {}

class TaskDetailLoaded extends TaskDetailState {
  final Task task;
  final List<ChecklistItem> checklistItems;

  TaskDetailLoaded({
    required this.task,
    required this.checklistItems,
  });
}

class TaskDetailError extends TaskDetailState {
  final String message;

  TaskDetailError(this.message);
}
