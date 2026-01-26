/// DTO para actualizar un sprint existente.
/// 
/// Todos los campos son opcionales, solo se actualizan los que se proporcionen.
/// Las validaciones de fechas y duración máxima (28 días) se aplican si se proporcionan fechas.
class UpdateSprintDto {
  /// Nuevo nombre del sprint (opcional, máximo 255 caracteres)
  final String? name;

  /// Nueva descripción del sprint (opcional)
  final String? description;

  /// Nuevos criterios de aceptación del sprint (objeto JSON opcional)
  final Map<String, dynamic>? acceptanceCriteria;

  /// Nueva fecha de inicio del sprint (formato: YYYY-MM-DD, opcional)
  final String? startDate;

  /// Nueva fecha de fin del sprint (formato: YYYY-MM-DD, opcional)
  /// Debe ser posterior a startDate y el período no debe exceder 28 días
  final String? endDate;

  /// Nuevos recursos disponibles para el sprint (objeto JSON opcional)
  final Map<String, dynamic>? resourcesAvailable;

  /// Nuevos recursos necesarios para el sprint (objeto JSON opcional)
  final Map<String, dynamic>? resourcesNeeded;

  /// Constructor del DTO para actualizar sprint
  UpdateSprintDto({
    this.name,
    this.description,
    this.acceptanceCriteria,
    this.startDate,
    this.endDate,
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
    if (acceptanceCriteria != null) json['acceptanceCriteria'] = acceptanceCriteria;
    if (startDate != null) json['startDate'] = startDate;
    if (endDate != null) json['endDate'] = endDate;
    if (resourcesAvailable != null) json['resourcesAvailable'] = resourcesAvailable;
    if (resourcesNeeded != null) json['resourcesNeeded'] = resourcesNeeded;
    return json;
  }
}
