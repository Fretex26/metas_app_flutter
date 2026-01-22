import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';

/// Caso de uso para actualizar un milestone existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para actualizar un milestone.
/// Solo se actualizan los campos proporcionados en el DTO (name y description).
class UpdateMilestoneUseCase {
  /// Repositorio de milestones para acceder a los datos
  final MilestoneRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de milestones inyectado
  UpdateMilestoneUseCase(this._repository);

  /// Ejecuta el caso de uso para actualizar un milestone.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// [dto] - Datos a actualizar (solo name y description)
  /// 
  /// Retorna el milestone actualizado.
  /// 
  /// Lanza una excepción si hay un error al actualizar el milestone.
  Future<Milestone> call(String projectId, String id, UpdateMilestoneDto dto) async {
    return await _repository.updateMilestone(projectId, id, dto);
  }
}
