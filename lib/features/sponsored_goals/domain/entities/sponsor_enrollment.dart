import 'package:metas_app/features/sponsored_goals/domain/entities/enrollment_status.dart';

/// Entidad que representa una inscripción de un usuario a un Sponsored Goal.
/// 
/// Cuando un usuario se inscribe a un Sponsored Goal, se crea un SponsorEnrollment
/// y se duplica automáticamente el proyecto del sponsor en los proyectos del usuario.
/// 
/// Estados posibles:
/// - `ACTIVE`: Inscripción activa, el usuario puede trabajar
/// - `INACTIVE`: Inscripción desactivada por el sponsor
/// - `COMPLETED`: Inscripción completada
class SponsorEnrollment {
  /// Identificador único de la inscripción (UUID)
  final String id;

  /// Identificador del sponsored goal al que se inscribió
  final String sponsoredGoalId;

  /// Identificador del usuario inscrito
  final String userId;

  /// Estado actual de la inscripción
  final EnrollmentStatus status;

  /// Fecha en que el usuario se inscribió
  final DateTime enrolledAt;

  /// Constructor de la entidad SponsorEnrollment
  SponsorEnrollment({
    required this.id,
    required this.sponsoredGoalId,
    required this.userId,
    required this.status,
    required this.enrolledAt,
  });
}
