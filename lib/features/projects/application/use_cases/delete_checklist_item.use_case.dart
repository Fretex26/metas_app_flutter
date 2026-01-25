import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';

/// Caso de uso para eliminar un checklist item existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para eliminar un checklist item.
/// Al eliminar un checklist item, el estado de la task se recalcula automáticamente.
class DeleteChecklistItemUseCase {
  /// Repositorio de checklist items para acceder a los datos
  final ChecklistItemRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de checklist items inyectado
  DeleteChecklistItemUseCase(this._repository);

  /// Ejecuta el caso de uso para eliminar un checklist item.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// 
  /// Lanza una excepción si hay un error al eliminar el checklist item.
  Future<void> call(String taskId, String id) async {
    return await _repository.deleteChecklistItem(taskId, id);
  }
}
