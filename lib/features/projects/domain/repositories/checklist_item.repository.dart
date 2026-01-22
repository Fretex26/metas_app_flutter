import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con checklist items.
/// 
/// Define los contratos para obtener, crear y actualizar checklist items dentro de tasks.
/// Esta interfaz es implementada por [ChecklistItemRepositoryImpl] en la capa de infraestructura.
/// 
/// Nota: Al actualizar un checklist item (especialmente isChecked), el estado de la task
/// se actualiza automáticamente en el backend según las reglas de dependencias.
abstract class ChecklistItemRepository {
  /// Obtiene todos los checklist items de una task específica.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// 
  /// Retorna una lista de checklist items asociados a la task.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<List<ChecklistItem>> getChecklistItems(String taskId);

  /// Obtiene un checklist item específico por su ID.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// 
  /// Retorna el checklist item si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItem> getChecklistItemById(String taskId, String id);

  /// Crea un nuevo checklist item dentro de una task.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [dto] - Datos del checklist item a crear
  /// 
  /// Retorna el checklist item creado con su ID asignado.
  /// 
  /// Nota: Al crear un checklist item, el estado de la task se actualiza automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItem> createChecklistItem(String taskId, CreateChecklistItemDto dto);

  /// Actualiza un checklist item existente.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// [dto] - Datos a actualizar (description, isRequired, isChecked)
  /// 
  /// Retorna el checklist item actualizado.
  /// 
  /// Nota: Al actualizar isChecked, el estado de la task se recalcula automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItem> updateChecklistItem(String taskId, String id, UpdateChecklistItemDto dto);

  /// Elimina un checklist item existente.
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// 
  /// Nota: Al eliminar un checklist item, el estado de la task se recalcula automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteChecklistItem(String taskId, String id);
}
