import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/milestone_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/milestone.mapper.dart';

/// Implementación concreta del repositorio de milestones.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class MilestoneRepositoryImpl implements MilestoneRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final MilestoneDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  MilestoneRepositoryImpl({MilestoneDatasource? datasource})
      : _datasource = datasource ?? MilestoneDatasource();

  @override
  Future<List<Milestone>> getProjectMilestones(String projectId) async {
    try {
      final dtos = await _datasource.getProjectMilestones(projectId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Milestone> getMilestoneById(String projectId, String milestoneId) async {
    try {
      final dto = await _datasource.getMilestoneById(projectId, milestoneId);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Milestone> createMilestone(String projectId, CreateMilestoneDto dto) async {
    try {
      final responseDto = await _datasource.createMilestone(projectId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Milestone> updateMilestone(String projectId, String id, UpdateMilestoneDto dto) async {
    try {
      final responseDto = await _datasource.updateMilestone(projectId, id, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMilestone(String projectId, String id) async {
    try {
      await _datasource.deleteMilestone(projectId, id);
    } catch (e) {
      rethrow;
    }
  }
}
