import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para obtener todas las categorías disponibles.
/// 
/// Este caso de uso encapsula la lógica de negocio para obtener la lista
/// de todas las categorías del catálogo, que pueden ser usadas para asociar
/// a los sponsored goals.
class GetCategoriesUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  GetCategoriesUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener todas las categorías.
  /// 
  /// Retorna una lista de todas las categorías disponibles.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Category>> call() async {
    return await _repository.getCategories();
  }
}
