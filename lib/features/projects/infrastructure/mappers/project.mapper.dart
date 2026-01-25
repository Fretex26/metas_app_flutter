import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/infrastructure/dto/project_response.dto.dart';

/// Extensión para mapear [ProjectResponseDto] a la entidad de dominio [Project].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime y manteniendo la estructura
/// de datos del dominio.
extension ProjectResponseDtoMapper on ProjectResponseDto {
  /// Convierte el DTO de respuesta a una entidad Project del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Mantiene los objetos JSON (resourcesAvailable, resourcesNeeded) sin cambios
  /// 
  /// Retorna una instancia de [Project] con todos los datos mapeados.
  Project toDomain() {
    return Project(
      id: id,
      userId: userId,
      name: name,
      description: description,
      purpose: purpose,
      budget: budget,
      finalDate: finalDate != null ? DateTime.parse(finalDate!) : null,
      resourcesAvailable: resourcesAvailable,
      resourcesNeeded: resourcesNeeded,
      sponsoredGoalId: sponsoredGoalId,
      enrollmentId: enrollmentId,
      isActive: isActive,
      rewardId: rewardId,
      createdAt: DateTime.parse(createdAt),
      status: status,
    );
  }
}
