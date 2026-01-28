import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/pending_sprints.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/pending_sprints_datasource.dart';

/// Implementación concreta del repositorio de sprints pendientes.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y convirtiendo DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class PendingSprintsRepositoryImpl implements PendingSprintsRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final PendingSprintsDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  PendingSprintsRepositoryImpl({PendingSprintsDatasource? datasource})
      : _datasource = datasource ?? PendingSprintsDatasource();

  @override
  Future<List<PendingSprint>> getPendingSprints() async {
    try {
      final dtos = await _datasource.getPendingSprints();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
