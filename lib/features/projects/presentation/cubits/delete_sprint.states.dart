/// Estados del cubit para eliminar sprints.
abstract class DeleteSprintState {}

/// Estado inicial del cubit
class DeleteSprintInitial extends DeleteSprintState {}

/// Estado de carga mientras se elimina el sprint
class DeleteSprintLoading extends DeleteSprintState {}

/// Estado de éxito cuando el sprint se elimina correctamente
class DeleteSprintSuccess extends DeleteSprintState {}

/// Estado de error cuando falla la eliminación del sprint
class DeleteSprintError extends DeleteSprintState {
  /// Mensaje de error
  final String message;

  DeleteSprintError(this.message);
}
