import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con proyectos.
/// 
/// Define los contratos para obtener, crear y gestionar proyectos.
/// Esta interfaz es implementada por [ProjectRepositoryImpl] en la capa de infraestructura.
abstract class ProjectRepository {
  /// Obtiene todos los proyectos del usuario autenticado.
  /// 
  /// Retorna una lista de proyectos asociados al usuario actual.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Project>> getUserProjects();

  /// Obtiene un proyecto específico por su ID.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Retorna el proyecto si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Project> getProjectById(String id);

  /// Obtiene el progreso calculado de un proyecto.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Retorna el progreso basado en tasks completadas vs total de tasks.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ProjectProgress> getProjectProgress(String id);

  /// Crea un nuevo proyecto para el usuario autenticado.
  /// 
  /// [dto] - Datos del proyecto a crear, incluyendo la recompensa obligatoria
  /// 
  /// Retorna el proyecto creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El usuario ya tiene 6 proyectos activos (400)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Project> createProject(CreateProjectDto dto);

  /// Actualiza un proyecto existente.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// [dto] - Datos a actualizar (solo los campos que se quieren cambiar)
  /// 
  /// Retorna el proyecto actualizado.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Project> updateProject(String id, UpdateProjectDto dto);

  /// Elimina un proyecto existente.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los milestones,
  /// sprints, tasks, checklist items y datos relacionados.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteProject(String id);
}
