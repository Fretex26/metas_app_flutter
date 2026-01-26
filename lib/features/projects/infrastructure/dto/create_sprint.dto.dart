/// DTO para crear un nuevo sprint dentro de un milestone.
/// 
/// Contiene los datos necesarios para crear un sprint, incluyendo fechas,
/// criterios de aceptación y recursos disponibles/necesarios.
class CreateSprintDto {
  /// Nombre del sprint (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del sprint
  final String? description;

  /// Criterios de aceptación del sprint (objeto JSON opcional)
  /// Formato: { "criterio1": "descripción", "criterio2": "descripción" }
  final Map<String, dynamic>? acceptanceCriteria;

  /// Fecha de inicio del sprint (formato: YYYY-MM-DD)
  final String startDate;

  /// Fecha de fin del sprint (formato: YYYY-MM-DD)
  /// Debe ser posterior a startDate y el período no debe exceder 28 días
  final String endDate;

  /// Recursos disponibles para el sprint (objeto JSON opcional)
  /// Formato: { "recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios para el sprint (objeto JSON opcional)
  /// Formato: { "recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// Constructor del DTO para crear sprint
  CreateSprintDto({
    required this.name,
    this.description,
    this.acceptanceCriteria,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (acceptanceCriteria != null) 'acceptanceCriteria': acceptanceCriteria,
      'startDate': startDate,
      'endDate': endDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
    };
  }
}
