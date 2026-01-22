/// DTO para actualizar una task existente.
/// 
/// Todos los campos son opcionales, solo se actualizan los que se proporcionen.
/// El estado de la task NO se puede editar directamente (se actualiza automáticamente
/// según los checklist items). Los campos `milestoneId` y `sprintId` no se pueden
/// editar mediante este endpoint.
class UpdateTaskDto {
  /// Nuevo nombre de la task (opcional, máximo 255 caracteres)
  final String? name;

  /// Nueva descripción de la task (opcional)
  final String? description;

  /// Nueva fecha de inicio (opcional, formato ISO date: 'YYYY-MM-DD')
  final String? startDate;

  /// Nueva fecha de fin (opcional, formato ISO date: 'YYYY-MM-DD')
  final String? endDate;

  /// Nuevos recursos disponibles (opcional, objeto JSON)
  final Map<String, dynamic>? resourcesAvailable;

  /// Nuevos recursos necesarios (opcional, objeto JSON)
  final Map<String, dynamic>? resourcesNeeded;

  /// Nuevos puntos de incentivo (opcional, mínimo 0)
  final int? incentivePoints;

  /// Constructor del DTO para actualizar task
  UpdateTaskDto({
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.incentivePoints,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  /// 
  /// Solo incluye los campos que no son null.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (startDate != null) json['startDate'] = startDate;
    if (endDate != null) json['endDate'] = endDate;
    if (resourcesAvailable != null) json['resourcesAvailable'] = resourcesAvailable;
    if (resourcesNeeded != null) json['resourcesNeeded'] = resourcesNeeded;
    if (incentivePoints != null) json['incentivePoints'] = incentivePoints;
    return json;
  }
}
