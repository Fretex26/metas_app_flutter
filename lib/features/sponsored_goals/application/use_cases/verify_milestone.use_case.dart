import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para verificar una milestone de un proyecto patrocinado.
/// 
/// Este caso de uso encapsula la lógica de negocio para verificar una milestone
/// de un proyecto patrocinado. Solo puede ser ejecutado por sponsors.
/// 
/// Cambia el estado de la milestone a "completed". Solo funciona para proyectos
/// con verificationMethod: MANUAL.
class VerifyMilestoneUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  VerifyMilestoneUseCase(this._repository);

  /// Ejecuta el caso de uso para verificar una milestone.
  /// 
  /// [milestoneId] - Identificador único de la milestone (UUID)
  /// 
  /// Retorna la milestone verificada con status "completed".
  /// 
  /// Lanza una excepción si:
  /// - La milestone no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El proyecto no es patrocinado (400)
  /// - El método de verificación no es MANUAL (400)
  /// - El usuario no está autenticado (401)
  Future<Milestone> call(String milestoneId) async {
    return await _repository.verifyMilestone(milestoneId);
  }
}
