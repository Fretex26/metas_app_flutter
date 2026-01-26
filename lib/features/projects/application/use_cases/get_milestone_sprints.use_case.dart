import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';

/// Use case para obtener todos los sprints de un milestone específico.
/// 
/// Retorna una lista de sprints asociados al milestone, ordenados por fecha de creación.
class GetMilestoneSprintsUseCase {
  final SprintRepository _repository;

  GetMilestoneSprintsUseCase(this._repository);

  /// Ejecuta la obtención de sprints del milestone.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna una lista de sprints asociados al milestone.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Sprint>> call(String milestoneId) async {
    return await _repository.getMilestoneSprints(milestoneId);
  }
}
