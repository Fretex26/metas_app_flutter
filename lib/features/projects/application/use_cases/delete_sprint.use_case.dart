import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';

/// Use case para eliminar un sprint existente.
/// 
/// El backend elimina automáticamente en cascada:
/// - Review asociada (si existe, relación 1:1)
/// - Retrospective asociada (si existe, relación 1:1)
/// - DailyEntries relacionados
/// - Las tasks NO se eliminan, solo quedan con sprintId = null
class DeleteSprintUseCase {
  final SprintRepository _repository;

  DeleteSprintUseCase(this._repository);

  /// Ejecuta la eliminación del sprint.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> call(String milestoneId, String sprintId) async {
    await _repository.deleteSprint(milestoneId, sprintId);
  }
}
