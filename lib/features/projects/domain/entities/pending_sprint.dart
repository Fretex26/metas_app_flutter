/// Entidad que representa un Sprint pendiente de review o retrospectiva.
/// 
/// Un sprint pendiente es aquel que ha finalizado (endDate <= hoy) y que aún
/// no tiene review o retrospectiva (o ambas) completadas.
class PendingSprint {
  /// Identificador único del sprint (UUID)
  final String sprintId;

  /// Nombre del sprint
  final String sprintName;

  /// Fecha de finalización del sprint
  final DateTime endDate;

  /// Identificador único del proyecto (UUID)
  final String projectId;

  /// Nombre del proyecto
  final String projectName;

  /// Identificador único del milestone (UUID)
  final String milestoneId;

  /// Nombre del milestone
  final String milestoneName;

  /// Indica si el sprint necesita review (no tiene review creada)
  final bool needsReview;

  /// Indica si el sprint necesita retrospectiva (no tiene retrospectiva creada)
  final bool needsRetrospective;

  /// Constructor de la entidad PendingSprint
  PendingSprint({
    required this.sprintId,
    required this.sprintName,
    required this.endDate,
    required this.projectId,
    required this.projectName,
    required this.milestoneId,
    required this.milestoneName,
    required this.needsReview,
    required this.needsRetrospective,
  });

  /// Verifica si el sprint necesita ambas (review y retrospectiva)
  bool get needsBoth => needsReview && needsRetrospective;

  /// Verifica si el sprint solo necesita review
  bool get needsOnlyReview => needsReview && !needsRetrospective;

  /// Verifica si el sprint solo necesita retrospectiva
  bool get needsOnlyRetrospective => !needsReview && needsRetrospective;
}
