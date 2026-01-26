import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con sprints.
/// 
/// Define los contratos para obtener, crear, actualizar y eliminar sprints dentro de milestones.
/// Esta interfaz es implementada por [SprintRepositoryImpl] en la capa de infraestructura.
abstract class SprintRepository {
  /// Obtiene todos los sprints de un milestone específico.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna una lista de sprints asociados al milestone.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Sprint>> getMilestoneSprints(String milestoneId);

  /// Obtiene un sprint específico por su ID.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna el sprint si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Sprint> getSprintById(String milestoneId, String sprintId);

  /// Crea un nuevo sprint dentro de un milestone.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos del sprint a crear
  /// 
  /// Retorna el sprint creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe o no pertenece al usuario (404)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<Sprint> createSprint(String milestoneId, CreateSprintDto dto);

  /// Actualiza un sprint existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos a actualizar (todos los campos son opcionales)
  /// 
  /// Retorna el sprint actualizado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<Sprint> updateSprint(String milestoneId, String sprintId, UpdateSprintDto dto);

  /// Elimina un sprint existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada:
  /// - Review asociada (si existe, relación 1:1)
  /// - Retrospective asociada (si existe, relación 1:1)
  /// - DailyEntries relacionados
  /// - Las tasks NO se eliminan, solo quedan con sprintId = null
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteSprint(String milestoneId, String sprintId);

  /// Obtiene todas las tasks de un sprint específico.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna una lista de tasks asociadas al sprint.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Task>> getSprintTasks(String milestoneId, String sprintId);
}
