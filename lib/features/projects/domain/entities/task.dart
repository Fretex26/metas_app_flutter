/// Entidad que representa una Task (Tarea) en el dominio de la aplicación.
/// 
/// Una task es una tarea específica dentro de un milestone que puede tener múltiples checklist items.
/// Las tasks tienen fechas de inicio y fin, y pueden tener puntos de incentivo.
/// 
/// Los estados posibles son:
/// - `pending`: Task sin iniciar
/// - `in_progress`: Task en progreso
/// - `completed`: Task completada
/// 
/// El estado se actualiza automáticamente según el estado de los checklist items asociados.
class Task {
  /// Identificador único de la task (UUID)
  final String id;

  /// Identificador del milestone al que pertenece esta task
  final String milestoneId;

  /// Identificador del sprint asociado (opcional)
  final String? sprintId;

  /// Nombre de la task (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional de la task
  final String? description;

  /// Estado actual de la task: 'pending', 'in_progress' o 'completed'
  final String status;

  /// Fecha de inicio de la task
  final DateTime startDate;

  /// Fecha de fin de la task (debe ser posterior a startDate)
  final DateTime endDate;

  /// Recursos disponibles para la task (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios para la task (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// Puntos de incentivo que se otorgan al completar la task
  final int? incentivePoints;

  /// Fecha de creación de la task
  final DateTime createdAt;

  /// Constructor de la entidad Task
  Task({
    required this.id,
    required this.milestoneId,
    this.sprintId,
    required this.name,
    this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.incentivePoints,
    required this.createdAt,
  });
}
