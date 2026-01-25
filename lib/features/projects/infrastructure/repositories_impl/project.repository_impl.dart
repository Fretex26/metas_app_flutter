import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/project_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/project.mapper.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/project_progress.mapper.dart';

/// Implementación concreta del repositorio de proyectos.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class ProjectRepositoryImpl implements ProjectRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final ProjectDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  ProjectRepositoryImpl({ProjectDatasource? datasource})
      : _datasource = datasource ?? ProjectDatasource();

  @override
  Future<List<Project>> getUserProjects() async {
    try {
      final dtos = await _datasource.getUserProjects();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Project> getProjectById(String id) async {
    try {
      final dto = await _datasource.getProjectById(id);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProjectProgress> getProjectProgress(String id) async {
    try {
      final dto = await _datasource.getProjectProgress(id);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Project> createProject(CreateProjectDto dto) async {
    try {
      final responseDto = await _datasource.createProject(dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Project> updateProject(String id, UpdateProjectDto dto) async {
    try {
      final responseDto = await _datasource.updateProject(id, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Project?> getProjectByRewardId(String rewardId) async {
    try {
      final dto = await _datasource.getProjectByRewardId(rewardId);
      if (dto == null) {
        return null;
      }
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _datasource.deleteProject(id);
    } catch (e) {
      rethrow;
    }
  }
}
