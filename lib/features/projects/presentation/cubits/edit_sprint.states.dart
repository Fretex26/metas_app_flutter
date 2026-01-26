/// Estados del cubit para editar sprints.
abstract class EditSprintState {}

/// Estado inicial del cubit
class EditSprintInitial extends EditSprintState {}

/// Estado de carga mientras se actualiza el sprint
class EditSprintLoading extends EditSprintState {}

/// Estado de éxito cuando el sprint se actualiza correctamente
class EditSprintSuccess extends EditSprintState {}

/// Estado de error cuando falla la actualización del sprint
class EditSprintError extends EditSprintState {
  /// Mensaje de error
  final String message;

  EditSprintError(this.message);
}
