import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';

/// Estados del cubit para el detalle de sprints.
abstract class SprintDetailState {}

/// Estado inicial del cubit
class SprintDetailInitial extends SprintDetailState {}

/// Estado de carga mientras se obtienen los datos
class SprintDetailLoading extends SprintDetailState {}

/// Estado cuando los datos se cargaron exitosamente
class SprintDetailLoaded extends SprintDetailState {
  /// Sprint cargado
  final Sprint sprint;

  /// Tasks asociadas al sprint
  final List<Task> tasks;

  SprintDetailLoaded({
    required this.sprint,
    required this.tasks,
  });
}

/// Estado de error cuando falla la carga
class SprintDetailError extends SprintDetailState {
  /// Mensaje de error
  final String message;

  SprintDetailError(this.message);
}
