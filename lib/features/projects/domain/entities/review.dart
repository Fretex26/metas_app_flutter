/// Entidad que representa una Review (Revisión) en el dominio de la aplicación.
/// 
/// Una review es una evaluación de un sprint que permite:
/// - Calcular y registrar el porcentaje de progreso del proyecto basado en tareas completadas
/// - Asignar puntos extra por logros adicionales
/// - Documentar un resumen de la revisión del sprint
/// 
/// Características principales:
/// - Relación 1:1 con Sprint (un sprint solo puede tener una review)
/// - El porcentaje de progreso se calcula automáticamente basado en las tareas completadas del proyecto
/// - Solo el dueño del proyecto puede crear/ver reviews de sus sprints
class Review {
  /// Identificador único de la review (UUID)
  final String id;

  /// Identificador del sprint al que pertenece esta review
  final String sprintId;

  /// Identificador del usuario que creó la review
  final String userId;

  /// Porcentaje de progreso calculado automáticamente (0-100)
  final int progressPercentage;

  /// Puntos extra otorgados (opcional, por defecto: 0)
  final int extraPoints;

  /// Resumen opcional de la revisión
  final String? summary;

  /// Fecha de creación de la review
  final DateTime createdAt;

  /// Constructor de la entidad Review
  Review({
    required this.id,
    required this.sprintId,
    required this.userId,
    required this.progressPercentage,
    required this.extraPoints,
    this.summary,
    required this.createdAt,
  });
}
