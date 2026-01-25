import 'package:metas_app/features/projects/domain/entities/reward.dart';
import 'package:metas_app/features/projects/domain/repositories/reward.repository.dart';

/// Caso de uso para obtener todas las recompensas del usuario autenticado.
/// 
/// Encapsula la lógica de negocio para obtener todas las recompensas asociadas
/// a los proyectos y milestones del usuario actual.
class GetUserRewardsUseCase {
  /// Repositorio de rewards
  final RewardRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de rewards
  GetUserRewardsUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener todas las recompensas del usuario.
  /// 
  /// Retorna una lista de todas las recompensas asociadas a los proyectos
  /// y milestones del usuario actual.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Reward>> call() async {
    return await _repository.getUserRewards();
  }
}
