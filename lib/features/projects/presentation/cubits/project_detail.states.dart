import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';

abstract class ProjectDetailState {}

class ProjectDetailInitial extends ProjectDetailState {}

class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  final Project project;
  final ProjectProgress progress;
  final List<Milestone> milestones;

  ProjectDetailLoaded({
    required this.project,
    required this.progress,
    required this.milestones,
  });
}

class ProjectDetailError extends ProjectDetailState {
  final String message;

  ProjectDetailError(this.message);
}
