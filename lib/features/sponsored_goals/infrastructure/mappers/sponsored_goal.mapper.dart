import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/verification_method.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/sponsored_goal_response.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/mappers/category.mapper.dart';

/// Extensión para mapear [SponsoredGoalResponseDto] a la entidad de dominio [SponsoredGoal].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime y strings de enum a enums.
extension SponsoredGoalResponseDtoMapper on SponsoredGoalResponseDto {
  /// Convierte el DTO de respuesta a una entidad SponsoredGoal del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Convierte string de verificationMethod a enum VerificationMethod
  /// - Mapea las categorías usando el mapper correspondiente
  /// 
  /// Retorna una instancia de [SponsoredGoal] con todos los datos mapeados.
  SponsoredGoal toDomain() {
    return SponsoredGoal(
      id: id,
      sponsorId: sponsorId,
      projectId: projectId,
      name: name,
      description: description,
      categories: categories?.map((c) => c.toDomain()).toList(),
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      verificationMethod: VerificationMethodExtension.fromString(
        verificationMethod,
      ),
      rewardId: rewardId,
      maxUsers: maxUsers,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
