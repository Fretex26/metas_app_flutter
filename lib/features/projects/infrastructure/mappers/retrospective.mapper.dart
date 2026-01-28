import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/infrastructure/dto/retrospective_response.dto.dart';

/// Extensión para mapear [RetrospectiveResponseDto] a la entidad de dominio [Retrospective].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension RetrospectiveResponseDtoMapper on RetrospectiveResponseDto {
  /// Convierte el DTO de respuesta a una entidad Retrospective del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// 
  /// Retorna una instancia de [Retrospective] con todos los datos mapeados.
  Retrospective toDomain() {
    return Retrospective(
      id: id,
      sprintId: sprintId,
      userId: userId,
      whatWentWell: whatWentWell,
      whatWentWrong: whatWentWrong,
      improvements: improvements,
      isPublic: isPublic,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
