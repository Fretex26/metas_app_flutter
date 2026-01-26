import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/infrastructure/dto/sprint_response.dto.dart';

/// Extensión para mapear [SprintResponseDto] a la entidad de dominio [Sprint].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension SprintResponseDtoMapper on SprintResponseDto {
  /// Convierte el DTO de respuesta a una entidad Sprint del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Preserva los objetos JSON (acceptanceCriteria, resourcesAvailable, resourcesNeeded)
  /// 
  /// Retorna una instancia de [Sprint] con todos los datos mapeados.
  Sprint toDomain() {
    return Sprint(
      id: id,
      milestoneId: milestoneId,
      name: name,
      description: description,
      acceptanceCriteria: acceptanceCriteria,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      resourcesAvailable: resourcesAvailable,
      resourcesNeeded: resourcesNeeded,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
