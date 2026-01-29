import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para obtener los Sponsored Goals disponibles.
/// 
/// Este caso de uso encapsula la lógica de negocio para obtener la lista de
/// sponsored goals disponibles para usuarios normales. Solo retorna objetivos
/// activos (fechas válidas y cupo disponible).
class GetAvailableSponsoredGoalsUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  GetAvailableSponsoredGoalsUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener los sponsored goals disponibles.
  /// 
  /// [categoryIds] - IDs de categorías opcionales para filtrar
  /// 
  /// Retorna una lista de sponsored goals disponibles.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<SponsoredGoal>> call({List<String>? categoryIds}) async {
    return await _repository.getAvailableSponsoredGoals(
      categoryIds: categoryIds,
    );
  }
}
