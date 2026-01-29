import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para obtener las milestones de un proyecto patrocinado.
/// 
/// Este caso de uso encapsula la lógica de negocio para obtener las milestones
/// de un proyecto patrocinado. Solo puede ser ejecutado por sponsors.
class GetSponsoredProjectMilestonesUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  GetSponsoredProjectMilestonesUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener las milestones de un proyecto patrocinado.
  /// 
  /// [projectId] - Identificador único del proyecto patrocinado (UUID)
  /// 
  /// Retorna una lista de milestones del proyecto.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El proyecto no es patrocinado (400)
  /// - El usuario no está autenticado (401)
  Future<List<Milestone>> call(String projectId) async {
    return await _repository.getSponsoredProjectMilestones(projectId);
  }
}
