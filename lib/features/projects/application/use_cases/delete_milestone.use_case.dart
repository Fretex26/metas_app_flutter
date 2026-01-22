import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';

/// Caso de uso para eliminar un milestone existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para eliminar un milestone.
/// El backend elimina automáticamente en cascada todos los sprints, tasks,
/// checklist items y datos relacionados.
class DeleteMilestoneUseCase {
  /// Repositorio de milestones para acceder a los datos
  final MilestoneRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de milestones inyectado
  DeleteMilestoneUseCase(this._repository);

  /// Ejecuta el caso de uso para eliminar un milestone.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// 
  /// Lanza una excepción si hay un error al eliminar el milestone.
  Future<void> call(String projectId, String id) async {
    return await _repository.deleteMilestone(projectId, id);
  }
}
