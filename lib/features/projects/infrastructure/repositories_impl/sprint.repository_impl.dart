import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/sprint_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/sprint.mapper.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/task.mapper.dart';

/// Implementación concreta del repositorio de sprints.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class SprintRepositoryImpl implements SprintRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final SprintDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  SprintRepositoryImpl({SprintDatasource? datasource})
      : _datasource = datasource ?? SprintDatasource();

  @override
  Future<List<Sprint>> getMilestoneSprints(String milestoneId) async {
    try {
      final dtos = await _datasource.getMilestoneSprints(milestoneId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sprint> getSprintById(String milestoneId, String sprintId) async {
    try {
      final dto = await _datasource.getSprintById(milestoneId, sprintId);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sprint> createSprint(String milestoneId, CreateSprintDto dto) async {
    try {
      final responseDto = await _datasource.createSprint(milestoneId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sprint> updateSprint(String milestoneId, String sprintId, UpdateSprintDto dto) async {
    try {
      final responseDto = await _datasource.updateSprint(milestoneId, sprintId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSprint(String milestoneId, String sprintId) async {
    try {
      await _datasource.deleteSprint(milestoneId, sprintId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Task>> getSprintTasks(String milestoneId, String sprintId) async {
    try {
      final dtos = await _datasource.getSprintTasks(milestoneId, sprintId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
