/// Sprint con una o más acciones pendientes (entrada diaria de hoy, review
/// y/o retrospectiva según corresponda).
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

  /// Indica si falta la entrada diaria de hoy para este sprint (sprint activo).
  final bool needsDaily;

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
    this.needsDaily = false,
  });

  /// Verifica si el sprint necesita ambas (review y retrospectiva)
  bool get needsBoth => needsReview && needsRetrospective;

  /// Verifica si el sprint solo necesita review
  bool get needsOnlyReview => needsReview && !needsRetrospective;

  /// Verifica si el sprint solo necesita retrospectiva
  bool get needsOnlyRetrospective => !needsReview && needsRetrospective;
}
