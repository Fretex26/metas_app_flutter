import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';

/// Caso de uso para obtener un proyecto por su rewardId.
/// 
/// Encapsula la lógica de negocio para buscar un proyecto que tenga
/// asociada una reward específica. Útil para verificar el estado del proyecto
/// cuando se visualiza el detalle de una reward.
class GetProjectByRewardIdUseCase {
  /// Repositorio de proyectos
  final ProjectRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de proyectos
  GetProjectByRewardIdUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener un proyecto por su rewardId.
  /// 
  /// [rewardId] - Identificador único de la reward (UUID)
  /// 
  /// Retorna el proyecto si existe y el usuario tiene permisos.
  /// Retorna null si no se encuentra ningún proyecto con ese rewardId.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<Project?> call(String rewardId) async {
    return await _repository.getProjectByRewardId(rewardId);
  }
}
