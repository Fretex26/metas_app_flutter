import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/infrastructure/dto/task_response.dto.dart';

/// Extensión para mapear [TaskResponseDto] a la entidad de dominio [Task].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime y manteniendo la estructura
/// de datos del dominio.
extension TaskResponseDtoMapper on TaskResponseDto {
  /// Convierte el DTO de respuesta a una entidad Task del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Mantiene los objetos JSON (resourcesAvailable, resourcesNeeded) sin cambios
  /// 
  /// Retorna una instancia de [Task] con todos los datos mapeados.
  Task toDomain() {
    return Task(
      id: id,
      milestoneId: milestoneId,
      sprintId: sprintId,
      name: name,
      description: description,
      status: status,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      resourcesAvailable: resourcesAvailable,
      resourcesNeeded: resourcesNeeded,
      incentivePoints: incentivePoints,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
