import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_enrollment_status.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_sponsored_goal.dto.dart';

/// Repositorio abstracto para operaciones relacionadas con Sponsored Goals.
/// 
/// Define el contrato que debe cumplir cualquier implementación del repositorio,
/// siguiendo el patrón Repository de Clean Architecture.
/// 
/// Este repositorio maneja:
/// - Creación de sponsored goals (solo sponsors)
/// - Listado de sponsored goals disponibles (usuarios normales)
/// - Inscripción a sponsored goals (usuarios normales)
/// - Actualización de estado de inscripciones (sponsors)
/// - Verificación de milestones (sponsors)
/// - Obtención de proyectos y milestones de usuarios (sponsors)
abstract class SponsoredGoalsRepository {
  /// Crea un nuevo Sponsored Goal.
  /// 
  /// Solo puede ser llamado por sponsors aprobados.
  /// 
  /// [dto] - Datos del sponsored goal a crear
  /// 
  /// Retorna el sponsored goal creado.
  Future<SponsoredGoal> createSponsoredGoal(CreateSponsoredGoalDto dto);

  /// Lista los Sponsored Goals del sponsor autenticado.
  /// 
  /// Retorna los objetivos creados por el sponsor.
  Future<List<SponsoredGoal>> listSponsorSponsoredGoals();

  /// Obtiene un Sponsored Goal por ID (solo si pertenece al sponsor).
  Future<SponsoredGoal> getSponsoredGoalById(String id);

  /// Actualiza un Sponsored Goal (PATCH parcial). Solo el sponsor dueño.
  Future<SponsoredGoal> updateSponsoredGoal(
    String id,
    UpdateSponsoredGoalDto dto,
  );

  /// Elimina un Sponsored Goal. Solo el sponsor dueño.
  Future<void> deleteSponsoredGoal(String id);

  /// Obtiene la lista de Sponsored Goals disponibles para usuarios normales.
  /// 
  /// Solo retorna objetivos activos (fechas válidas y cupo disponible).
  /// 
  /// [categoryIds] - IDs de categorías opcionales para filtrar
  /// 
  /// Retorna una lista de sponsored goals disponibles.
  Future<List<SponsoredGoal>> getAvailableSponsoredGoals({
    List<String>? categoryIds,
  });

  /// Inscribe a un usuario normal a un Sponsored Goal.
  /// 
  /// Automáticamente duplica el proyecto del sponsor en los proyectos del usuario.
  /// 
  /// [sponsoredGoalId] - Identificador único del sponsored goal
  /// 
  /// Retorna la inscripción creada.
  Future<SponsorEnrollment> enrollInSponsoredGoal(String sponsoredGoalId);

  /// Actualiza el estado de una inscripción.
  /// 
  /// Solo puede ser llamado por sponsors.
  /// 
  /// [enrollmentId] - Identificador único de la inscripción
  /// [dto] - DTO con el nuevo estado
  /// 
  /// Retorna la inscripción actualizada.
  Future<SponsorEnrollment> updateEnrollmentStatus(
    String enrollmentId,
    UpdateEnrollmentStatusDto dto,
  );

  /// Verifica una milestone de un proyecto patrocinado.
  /// 
  /// Solo puede ser llamado por sponsors.
  /// Cambia el estado de la milestone a "completed".
  /// 
  /// [milestoneId] - Identificador único de la milestone
  /// 
  /// Retorna la milestone verificada.
  Future<Milestone> verifyMilestone(String milestoneId);

  /// Obtiene los proyectos patrocinados de un usuario.
  /// 
  /// Solo puede ser llamado por sponsors.
  /// Solo retorna proyectos de los sponsored goals del sponsor que hace la petición.
  /// 
  /// [userEmail] - Email del usuario
  /// 
  /// Retorna una lista de proyectos patrocinados del usuario.
  Future<List<Project>> getUserSponsoredProjects(String userEmail);

  /// Obtiene las milestones de un proyecto patrocinado.
  /// 
  /// Solo puede ser llamado por sponsors.
  /// 
  /// [projectId] - Identificador único del proyecto patrocinado
  /// 
  /// Retorna una lista de milestones del proyecto.
  Future<List<Milestone>> getSponsoredProjectMilestones(String projectId);

  /// Obtiene todas las categorías disponibles.
  /// 
  /// Retorna una lista de todas las categorías del catálogo.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Category>> getCategories();
}
