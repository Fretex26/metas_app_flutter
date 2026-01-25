/// DTO para actualizar un proyecto existente.
/// 
/// Todos los campos son opcionales, solo se actualizan los que se proporcionen.
/// El estado del proyecto NO se puede editar directamente (se actualiza automáticamente).
/// Los campos `rewardId`, `sponsoredGoalId`, `enrollmentId`, `isActive` y `status` 
/// NO se pueden editar mediante este endpoint.
class UpdateProjectDto {
  /// Nuevo nombre del proyecto (opcional, máximo 255 caracteres)
  final String? name;

  /// Nueva descripción del proyecto (opcional)
  final String? description;

  /// Nuevo propósito del proyecto (opcional)
  final String? purpose;

  /// Nuevo presupuesto del proyecto (opcional)
  final double? budget;

  /// Nueva fecha final del proyecto (opcional, formato ISO date: 'YYYY-MM-DD')
  final String? finalDate;

  /// Nuevos recursos disponibles (opcional, objeto JSON)
  final Map<String, dynamic>? resourcesAvailable;

  /// Nuevos recursos necesarios (opcional, objeto JSON)
  final Map<String, dynamic>? resourcesNeeded;

  /// Constructor del DTO para actualizar proyecto
  UpdateProjectDto({
    this.name,
    this.description,
    this.purpose,
    this.budget,
    this.finalDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  /// 
  /// Solo incluye los campos que no son null.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (purpose != null) json['purpose'] = purpose;
    if (budget != null) json['budget'] = budget;
    if (finalDate != null) json['finalDate'] = finalDate;
    if (resourcesAvailable != null) json['resourcesAvailable'] = resourcesAvailable;
    if (resourcesNeeded != null) json['resourcesNeeded'] = resourcesNeeded;
    return json;
  }
}
