import 'package:metas_app/features/projects/domain/entities/reward.dart';
import 'package:metas_app/features/projects/domain/repositories/reward.repository.dart';

/// Caso de uso para obtener una recompensa por su ID.
/// 
/// Encapsula la lógica de negocio para obtener los detalles de una recompensa específica.
class GetRewardByIdUseCase {
  /// Repositorio de rewards
  final RewardRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de rewards
  GetRewardByIdUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener una recompensa por su ID.
  /// 
  /// [id] - Identificador único de la recompensa (UUID)
  /// 
  /// Retorna la recompensa si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - La recompensa no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Reward> call(String id) async {
    return await _repository.getRewardById(id);
  }
}
