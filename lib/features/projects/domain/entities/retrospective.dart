/// Entidad que representa una Retrospective (Retrospectiva) en el dominio de la aplicación.
/// 
/// Una retrospectiva es un análisis reflexivo de un sprint que permite:
/// - Documentar lo que salió bien durante el sprint
/// - Documentar lo que salió mal durante el sprint
/// - Proponer mejoras para futuros sprints
/// - Marcar retrospectivas como públicas o privadas
/// 
/// Características principales:
/// - Relación 1:1 con Sprint (un sprint solo puede tener una retrospectiva)
/// - Pueden ser públicas (visibles para todos) o privadas (solo para el dueño)
/// - Solo el dueño del proyecto puede crear retrospectivas de sus sprints
class Retrospective {
  /// Identificador único de la retrospectiva (UUID)
  final String id;

  /// Identificador del sprint al que pertenece esta retrospectiva
  final String sprintId;

  /// Identificador del usuario que creó la retrospectiva
  final String userId;

  /// Lo que salió bien durante el sprint (requerido)
  final String whatWentWell;

  /// Lo que salió mal durante el sprint (requerido)
  final String whatWentWrong;

  /// Mejoras propuestas para futuros sprints (opcional)
  final String? improvements;

  /// Indica si la retrospectiva es pública (true) o privada (false)
  final bool isPublic;

  /// Fecha de creación de la retrospectiva
  final DateTime createdAt;

  /// Constructor de la entidad Retrospective
  Retrospective({
    required this.id,
    required this.sprintId,
    required this.userId,
    required this.whatWentWell,
    required this.whatWentWrong,
    this.improvements,
    required this.isPublic,
    required this.createdAt,
  });
}
