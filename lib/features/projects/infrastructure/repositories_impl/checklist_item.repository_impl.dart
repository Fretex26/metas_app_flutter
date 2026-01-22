import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/checklist_item_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/checklist_item.mapper.dart';

/// Implementación concreta del repositorio de checklist items.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
/// 
/// Nota: Al crear o actualizar checklist items, el estado de la task se actualiza
/// automáticamente en el backend según las reglas de dependencias.
class ChecklistItemRepositoryImpl implements ChecklistItemRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final ChecklistItemDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  ChecklistItemRepositoryImpl({ChecklistItemDatasource? datasource})
      : _datasource = datasource ?? ChecklistItemDatasource();

  @override
  Future<List<ChecklistItem>> getChecklistItems(String taskId) async {
    try {
      final dtos = await _datasource.getChecklistItems(taskId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChecklistItem> getChecklistItemById(String taskId, String id) async {
    try {
      final dto = await _datasource.getChecklistItemById(taskId, id);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChecklistItem> createChecklistItem(String taskId, CreateChecklistItemDto dto) async {
    try {
      final responseDto = await _datasource.createChecklistItem(taskId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChecklistItem> updateChecklistItem(String taskId, String id, UpdateChecklistItemDto dto) async {
    try {
      final responseDto = await _datasource.updateChecklistItem(taskId, id, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteChecklistItem(String taskId, String id) async {
    try {
      await _datasource.deleteChecklistItem(taskId, id);
    } catch (e) {
      rethrow;
    }
  }
}
