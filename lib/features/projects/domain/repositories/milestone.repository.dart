import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con milestones.
/// 
/// Define los contratos para obtener y crear milestones dentro de proyectos.
/// Esta interfaz es implementada por [MilestoneRepositoryImpl] en la capa de infraestructura.
abstract class MilestoneRepository {
  /// Obtiene todos los milestones de un proyecto específico.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// 
  /// Retorna una lista de milestones asociados al proyecto.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<Milestone>> getProjectMilestones(String projectId);

  /// Obtiene un milestone específico por su ID.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna el milestone si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Milestone> getMilestoneById(String projectId, String milestoneId);

  /// Crea un nuevo milestone dentro de un proyecto.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [dto] - Datos del milestone a crear, incluyendo recompensa opcional
  /// 
  /// Retorna el milestone creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe o no pertenece al usuario (404)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Milestone> createMilestone(String projectId, CreateMilestoneDto dto);

  /// Actualiza un milestone existente.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// [dto] - Datos a actualizar (solo name y description)
  /// 
  /// Retorna el milestone actualizado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Milestone> updateMilestone(String projectId, String id, UpdateMilestoneDto dto);

  /// Elimina un milestone existente.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los sprints,
  /// tasks, checklist items y datos relacionados.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteMilestone(String projectId, String id);
}
