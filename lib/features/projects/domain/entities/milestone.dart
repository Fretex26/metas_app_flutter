/// Entidad que representa un Milestone (Hito) en el dominio de la aplicación.
/// 
/// Un milestone es una fase o etapa dentro de un proyecto que agrupa múltiples tasks.
/// Los milestones pueden tener una recompensa opcional asociada.
/// 
/// Los estados posibles son:
/// - `pending`: Milestone sin iniciar
/// - `in_progress`: Milestone en progreso
/// - `completed`: Milestone completado
/// 
/// El estado se actualiza automáticamente según el estado de las tasks asociadas.
class Milestone {
  /// Identificador único del milestone (UUID)
  final String id;

  /// Identificador del proyecto al que pertenece este milestone
  final String projectId;

  /// Nombre del milestone (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del milestone
  final String? description;

  /// Estado actual del milestone: 'pending', 'in_progress' o 'completed'
  final String status;

  /// ID de la recompensa asociada (opcional)
  final String? rewardId;

  /// Fecha de creación del milestone
  final DateTime createdAt;

  /// Constructor de la entidad Milestone
  Milestone({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.status,
    this.rewardId,
    required this.createdAt,
  });
}
