import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/domain/repositories/retrospective.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/retrospective_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/retrospective.mapper.dart';

/// Implementación concreta del repositorio de retrospectivas.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class RetrospectiveRepositoryImpl implements RetrospectiveRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final RetrospectiveDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  RetrospectiveRepositoryImpl({RetrospectiveDatasource? datasource})
      : _datasource = datasource ?? RetrospectiveDatasource();

  @override
  Future<Retrospective?> getSprintRetrospective(String sprintId) async {
    try {
      final dto = await _datasource.getSprintRetrospective(sprintId);
      return dto?.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Retrospective> createRetrospective(String sprintId, CreateRetrospectiveDto dto) async {
    try {
      final responseDto = await _datasource.createRetrospective(sprintId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Retrospective>> getPublicRetrospectives() async {
    try {
      final dtos = await _datasource.getPublicRetrospectives();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
