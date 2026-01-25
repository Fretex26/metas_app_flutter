import 'package:metas_app/features/projects/domain/entities/reward.dart';
import 'package:metas_app/features/projects/infrastructure/dto/reward_response.dto.dart';

/// Extensión para mapear [RewardResponseDto] a la entidad de dominio [Reward].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// manteniendo la estructura de datos del dominio.
extension RewardResponseDtoMapper on RewardResponseDto {
  /// Convierte el DTO de respuesta a una entidad Reward del dominio.
  /// 
  /// Retorna una instancia de [Reward] con todos los datos mapeados.
  Reward toDomain() {
    return Reward(
      id: id,
      name: name,
      description: description,
      claimInstructions: claimInstructions,
      claimLink: claimLink,
    );
  }
}
