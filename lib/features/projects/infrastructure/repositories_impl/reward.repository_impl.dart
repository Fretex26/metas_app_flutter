import 'package:metas_app/features/projects/domain/entities/reward.dart';
import 'package:metas_app/features/projects/domain/repositories/reward.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/reward_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/reward.mapper.dart';

/// Implementación concreta del repositorio de rewards (recompensas).
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class RewardRepositoryImpl implements RewardRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final RewardDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  RewardRepositoryImpl({RewardDatasource? datasource})
      : _datasource = datasource ?? RewardDatasource();

  @override
  Future<Reward> getRewardById(String id) async {
    try {
      final dto = await _datasource.getRewardById(id);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Reward>> getUserRewards() async {
    try {
      final dtos = await _datasource.getUserRewards();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
