import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/infrastructure/dto/checklist_item_response.dto.dart';

/// Extensión para mapear [ChecklistItemResponseDto] a la entidad de dominio [ChecklistItem].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension ChecklistItemResponseDtoMapper on ChecklistItemResponseDto {
  /// Convierte el DTO de respuesta a una entidad ChecklistItem del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// 
  /// Retorna una instancia de [ChecklistItem] con todos los datos mapeados.
  ChecklistItem toDomain() {
    return ChecklistItem(
      id: id,
      taskId: taskId,
      description: description,
      isRequired: isRequired,
      isChecked: isChecked,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
