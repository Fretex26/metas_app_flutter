import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para inscribirse a un Sponsored Goal.
/// 
/// Este caso de uso encapsula la lógica de negocio para inscribir a un usuario
/// normal a un sponsored goal. Automáticamente se duplica el proyecto del sponsor
/// en los proyectos del usuario.
class EnrollInSponsoredGoalUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  EnrollInSponsoredGoalUseCase(this._repository);

  /// Ejecuta el caso de uso para inscribirse a un sponsored goal.
  /// 
  /// [sponsoredGoalId] - Identificador único del sponsored goal (UUID)
  /// 
  /// Retorna la inscripción creada. El proyecto se duplica automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El sponsored goal no existe (404)
  /// - El usuario ya está inscrito (409)
  /// - Se alcanzó el número máximo de usuarios (400)
  /// - El usuario no está autenticado (401)
  Future<SponsorEnrollment> call(String sponsoredGoalId) async {
    return await _repository.enrollInSponsoredGoal(sponsoredGoalId);
  }
}
