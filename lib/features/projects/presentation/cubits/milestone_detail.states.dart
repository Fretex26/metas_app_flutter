import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';

abstract class MilestoneDetailState {}

class MilestoneDetailInitial extends MilestoneDetailState {}

class MilestoneDetailLoading extends MilestoneDetailState {}

class MilestoneDetailLoaded extends MilestoneDetailState {
  final Milestone milestone;
  final List<Task> tasks;

  MilestoneDetailLoaded({
    required this.milestone,
    required this.tasks,
  });
}

class MilestoneDetailError extends MilestoneDetailState {
  final String message;

  MilestoneDetailError(this.message);
}
