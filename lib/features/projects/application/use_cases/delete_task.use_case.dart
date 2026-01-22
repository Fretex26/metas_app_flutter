import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';

/// Caso de uso para eliminar una task existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para eliminar una task.
/// El backend elimina automáticamente en cascada todos los checklist items
/// y daily entries relacionados.
class DeleteTaskUseCase {
  /// Repositorio de tasks para acceder a los datos
  final TaskRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de tasks inyectado
  DeleteTaskUseCase(this._repository);

  /// Ejecuta el caso de uso para eliminar una task.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// 
  /// Lanza una excepción si hay un error al eliminar la task.
  Future<void> call(String milestoneId, String id) async {
    return await _repository.deleteTask(milestoneId, id);
  }
}
