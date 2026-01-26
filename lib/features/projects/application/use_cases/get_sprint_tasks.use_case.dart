import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';

/// Use case para obtener todas las tasks de un sprint específico.
/// 
/// Retorna una lista de tasks asociadas al sprint, ordenadas por fecha de creación.
class GetSprintTasksUseCase {
  final SprintRepository _repository;

  GetSprintTasksUseCase(this._repository);

  /// Ejecuta la obtención de tasks del sprint.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna una lista de tasks asociadas al sprint.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Task>> call(String milestoneId, String sprintId) async {
    return await _repository.getSprintTasks(milestoneId, sprintId);
  }
}
