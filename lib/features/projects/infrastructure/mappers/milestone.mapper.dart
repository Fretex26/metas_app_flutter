import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/infrastructure/dto/milestone_response.dto.dart';

/// Extensión para mapear [MilestoneResponseDto] a la entidad de dominio [Milestone].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension MilestoneResponseDtoMapper on MilestoneResponseDto {
  /// Convierte el DTO de respuesta a una entidad Milestone del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// 
  /// Retorna una instancia de [Milestone] con todos los datos mapeados.
  Milestone toDomain() {
    return Milestone(
      id: id,
      projectId: projectId,
      name: name,
      description: description,
      status: status,
      rewardId: rewardId,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
