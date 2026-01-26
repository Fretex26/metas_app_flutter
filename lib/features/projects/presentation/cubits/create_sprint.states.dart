/// Estados del cubit para crear sprints.
abstract class CreateSprintState {}

/// Estado inicial del cubit
class CreateSprintInitial extends CreateSprintState {}

/// Estado de carga mientras se crea el sprint
class CreateSprintLoading extends CreateSprintState {}

/// Estado de éxito cuando el sprint se crea correctamente
class CreateSprintSuccess extends CreateSprintState {
  /// ID del sprint creado
  final String sprintId;

  CreateSprintSuccess(this.sprintId);
}

/// Estado de error cuando falla la creación del sprint
class CreateSprintError extends CreateSprintState {
  /// Mensaje de error
  final String message;

  CreateSprintError(this.message);
}
