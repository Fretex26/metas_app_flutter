/// DTO para crear una nueva task dentro de un milestone.
/// 
/// Contiene los datos necesarios para crear una task, incluyendo fechas
/// de inicio y fin, recursos y puntos de incentivo opcionales.
class CreateTaskDto {
  /// Identificador del milestone al que pertenece la task (requerido)
  final String milestoneId;

  /// Identificador del sprint asociado (opcional)
  final String? sprintId;

  /// Nombre de la task (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional de la task
  final String? description;

  /// Fecha de inicio en formato ISO date: YYYY-MM-DD (requerida)
  final String startDate;

  /// Fecha de fin en formato ISO date: YYYY-MM-DD (requerida)
  /// Debe ser posterior a startDate
  final String endDate;

  /// Recursos disponibles (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// Puntos de incentivo que se otorgan al completar la task (mínimo 0)
  final int? incentivePoints;

  /// Constructor del DTO para crear task
  CreateTaskDto({
    required this.milestoneId,
    this.sprintId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.incentivePoints,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      if (sprintId != null) 'sprintId': sprintId,
      'name': name,
      if (description != null) 'description': description,
      'startDate': startDate,
      'endDate': endDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
      if (incentivePoints != null) 'incentivePoints': incentivePoints,
    };
  }
}
