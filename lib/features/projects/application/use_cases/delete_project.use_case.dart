import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';

/// Caso de uso para eliminar un proyecto existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para eliminar un proyecto.
/// El backend elimina automáticamente en cascada todos los milestones, sprints,
/// tasks, checklist items y datos relacionados.
class DeleteProjectUseCase {
  /// Repositorio de proyectos para acceder a los datos
  final ProjectRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de proyectos inyectado
  DeleteProjectUseCase(this._repository);

  /// Ejecuta el caso de uso para eliminar un proyecto.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Lanza una excepción si hay un error al eliminar el proyecto.
  Future<void> call(String id) async {
    return await _repository.deleteProject(id);
  }
}
