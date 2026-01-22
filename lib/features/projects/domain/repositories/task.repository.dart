import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con tasks.
/// 
/// Define los contratos para obtener y crear tasks dentro de milestones.
/// Esta interfaz es implementada por [TaskRepositoryImpl] en la capa de infraestructura.
abstract class TaskRepository {
  /// Obtiene todas las tasks de un milestone específico.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna una lista de tasks asociadas al milestone.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Task>> getMilestoneTasks(String milestoneId);

  /// Obtiene una task específica por su ID.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [taskId] - Identificador único de la task (UUID)
  /// 
  /// Retorna la task si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Task> getTaskById(String milestoneId, String taskId);

  /// Crea una nueva task dentro de un milestone.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos de la task a crear, incluyendo fechas y recursos
  /// 
  /// Retorna la task creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone o sprint no existe (404)
  /// - El período de la task excede el del sprint (400)
  /// - Las fechas son inválidas (400)
  /// - El usuario no está autenticado (401)
  Future<Task> createTask(String milestoneId, CreateTaskDto dto);

  /// Actualiza una task existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// [dto] - Datos a actualizar (name, description, fechas, recursos, puntos)
  /// 
  /// Retorna la task actualizada.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Task> updateTask(String milestoneId, String id, UpdateTaskDto dto);

  /// Elimina una task existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los checklist items
  /// y daily entries relacionados.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteTask(String milestoneId, String id);
}
