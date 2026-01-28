import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/infrastructure/dto/review_response.dto.dart';

/// Extensión para mapear [ReviewResponseDto] a la entidad de dominio [Review].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension ReviewResponseDtoMapper on ReviewResponseDto {
  /// Convierte el DTO de respuesta a una entidad Review del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// 
  /// Retorna una instancia de [Review] con todos los datos mapeados.
  Review toDomain() {
    return Review(
      id: id,
      sprintId: sprintId,
      userId: userId,
      progressPercentage: progressPercentage,
      extraPoints: extraPoints,
      summary: summary,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
