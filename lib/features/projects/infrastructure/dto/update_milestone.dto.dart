/// DTO para actualizar un milestone existente.
/// 
/// Todos los campos son opcionales, solo se actualizan los que se proporcionen.
/// El estado del milestone NO se puede editar directamente (se actualiza automáticamente
/// según las tasks). El campo `rewardId` NO se puede editar mediante este endpoint.
class UpdateMilestoneDto {
  /// Nuevo nombre del milestone (opcional, máximo 255 caracteres)
  final String? name;

  /// Nueva descripción del milestone (opcional)
  final String? description;

  /// Constructor del DTO para actualizar milestone
  UpdateMilestoneDto({
    this.name,
    this.description,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  /// 
  /// Solo incluye los campos que no son null.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    return json;
  }
}
