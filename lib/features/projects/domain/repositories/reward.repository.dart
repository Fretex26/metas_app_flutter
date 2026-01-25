import 'package:metas_app/features/projects/domain/entities/reward.dart';

/// Interfaz del repositorio para operaciones relacionadas con rewards (recompensas).
/// 
/// Define los contratos para obtener recompensas.
/// Esta interfaz es implementada por [RewardRepositoryImpl] en la capa de infraestructura.
abstract class RewardRepository {
  /// Obtiene una recompensa específica por su ID.
  /// 
  /// [id] - Identificador único de la recompensa (UUID)
  /// 
  /// Retorna la recompensa si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - La recompensa no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Reward> getRewardById(String id);

  /// Obtiene todas las recompensas del usuario autenticado.
  /// 
  /// Retorna una lista de todas las recompensas asociadas a los proyectos
  /// y milestones del usuario actual.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Reward>> getUserRewards();
}
