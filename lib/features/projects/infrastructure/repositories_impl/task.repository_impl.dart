import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/task_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/task.mapper.dart';

/// Implementación concreta del repositorio de tasks.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class TaskRepositoryImpl implements TaskRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final TaskDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  TaskRepositoryImpl({TaskDatasource? datasource})
      : _datasource = datasource ?? TaskDatasource();

  @override
  Future<List<Task>> getMilestoneTasks(String milestoneId) async {
    try {
      final dtos = await _datasource.getMilestoneTasks(milestoneId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> getTaskById(String milestoneId, String taskId) async {
    try {
      final dto = await _datasource.getTaskById(milestoneId, taskId);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> createTask(String milestoneId, CreateTaskDto dto) async {
    try {
      final responseDto = await _datasource.createTask(milestoneId, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> updateTask(String milestoneId, String id, UpdateTaskDto dto) async {
    try {
      final responseDto = await _datasource.updateTask(milestoneId, id, dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String milestoneId, String id) async {
    try {
      await _datasource.deleteTask(milestoneId, id);
    } catch (e) {
      rethrow;
    }
  }
}
