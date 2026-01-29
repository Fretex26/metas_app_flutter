import 'package:metas_app/features/sponsored_goals/domain/entities/enrollment_status.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/sponsor_enrollment_response.dto.dart';

/// Extensión para mapear [SponsorEnrollmentResponseDto] a la entidad de dominio [SponsorEnrollment].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime y strings de enum a enums.
extension SponsorEnrollmentResponseDtoMapper on SponsorEnrollmentResponseDto {
  /// Convierte el DTO de respuesta a una entidad SponsorEnrollment del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Convierte string de status a enum EnrollmentStatus
  /// 
  /// Retorna una instancia de [SponsorEnrollment] con todos los datos mapeados.
  SponsorEnrollment toDomain() {
    return SponsorEnrollment(
      id: id,
      sponsoredGoalId: sponsoredGoalId,
      userId: userId,
      status: EnrollmentStatusExtension.fromString(status),
      enrolledAt: DateTime.parse(enrolledAt),
    );
  }
}
