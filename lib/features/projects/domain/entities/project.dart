/// Entidad que representa un Proyecto en el dominio de la aplicación.
/// 
/// Un proyecto es la entidad principal que agrupa milestones, tasks y checklist items.
/// Cada proyecto debe tener una recompensa asociada y puede tener un máximo de 6 proyectos activos por usuario.
/// 
/// Los estados posibles son:
/// - `pending`: Proyecto sin iniciar
/// - `in_progress`: Proyecto en progreso
/// - `completed`: Proyecto completado
class Project {
  /// Identificador único del proyecto (UUID)
  final String id;

  /// Identificador del usuario propietario del proyecto
  final String userId;

  /// Nombre del proyecto (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del proyecto
  final String? description;

  /// Propósito u objetivo del proyecto
  final String? purpose;

  /// Presupuesto asignado al proyecto
  final double? budget;

  /// Fecha límite para completar el proyecto
  final DateTime? finalDate;

  /// Recursos disponibles para el proyecto (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios para el proyecto (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// ID del goal patrocinado (si el proyecto es patrocinado)
  final String? sponsoredGoalId;

  /// ID de la inscripción asociada
  final String? enrollmentId;

  /// Indica si el proyecto está activo
  final bool isActive;

  /// ID de la recompensa asociada al proyecto (obligatoria)
  final String rewardId;

  /// Fecha de creación del proyecto
  final DateTime createdAt;

  /// Estado actual del proyecto: 'pending', 'in_progress' o 'completed'
  /// Se actualiza automáticamente según el estado de los milestones
  final String? status;

  /// Constructor de la entidad Project
  Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.purpose,
    this.budget,
    this.finalDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.sponsoredGoalId,
    this.enrollmentId,
    required this.isActive,
    required this.rewardId,
    required this.createdAt,
    this.status,
  });
}
