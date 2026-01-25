import 'package:metas_app/features/projects/domain/entities/project.dart';

/// Estados posibles para la edición de proyectos.
/// 
/// Define los diferentes estados que puede tener el proceso de edición:
/// - [EditProjectInitial]: Estado inicial
/// - [EditProjectLoading]: Cargando/actualizando
/// - [EditProjectSuccess]: Actualización exitosa
/// - [EditProjectError]: Error durante la actualización
abstract class EditProjectState {}

/// Estado inicial de la edición de proyecto.
class EditProjectInitial extends EditProjectState {}

/// Estado de carga durante la actualización del proyecto.
class EditProjectLoading extends EditProjectState {}

/// Estado de éxito después de actualizar el proyecto.
/// 
/// Contiene el proyecto actualizado.
class EditProjectSuccess extends EditProjectState {
  /// Proyecto actualizado
  final Project project;

  /// Constructor del estado de éxito
  EditProjectSuccess(this.project);
}

/// Estado de error durante la actualización del proyecto.
/// 
/// Contiene el mensaje de error.
class EditProjectError extends EditProjectState {
  /// Mensaje de error
  final String message;

  /// Constructor del estado de error
  EditProjectError(this.message);
}
