import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_enrollment_status.dto.dart';

/// Caso de uso para actualizar el estado de una inscripción.
/// 
/// Este caso de uso encapsula la lógica de negocio para actualizar el estado
/// de una inscripción a un sponsored goal. Solo puede ser ejecutado por sponsors.
/// 
/// Cuando se cambia a INACTIVE, el proyecto del usuario se marca como isActive: false
/// pero no se elimina.
class UpdateEnrollmentStatusUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  UpdateEnrollmentStatusUseCase(this._repository);

  /// Ejecuta el caso de uso para actualizar el estado de una inscripción.
  /// 
  /// [enrollmentId] - Identificador único de la inscripción (UUID)
  /// [dto] - DTO con el nuevo estado (ACTIVE, INACTIVE, COMPLETED)
  /// 
  /// Retorna la inscripción actualizada.
  /// 
  /// Lanza una excepción si:
  /// - El enrollment no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El usuario no está autenticado (401)
  Future<SponsorEnrollment> call(
    String enrollmentId,
    UpdateEnrollmentStatusDto dto,
  ) async {
    return await _repository.updateEnrollmentStatus(enrollmentId, dto);
  }
}
