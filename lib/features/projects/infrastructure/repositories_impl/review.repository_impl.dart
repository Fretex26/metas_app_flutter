import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/domain/repositories/review.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/review_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/review.mapper.dart';

/// Implementación concreta del repositorio de reviews.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class ReviewRepositoryImpl implements ReviewRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final ReviewDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  ReviewRepositoryImpl({ReviewDatasource? datasource})
      : _datasource = datasource ?? ReviewDatasource();

  @override
  Future<Review?> getSprintReview(String sprintId) async {
    try {
      final dto = await _datasource.getSprintReview(sprintId);
      return dto?.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Review> createReview(String sprintId, CreateReviewDto dto) async {
    try {
      final responseDto = await _datasource.createReview(sprintId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }
}
