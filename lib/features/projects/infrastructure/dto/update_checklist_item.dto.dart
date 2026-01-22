/// DTO para actualizar un checklist item existente.
/// 
/// Todos los campos son opcionales, solo se actualizan los que se proporcionen.
/// Al actualizar `isChecked`, el estado de la task se recalcula automáticamente
/// en el backend según las reglas de dependencias.
class UpdateChecklistItemDto {
  /// Nueva descripción del item (opcional)
  final String? description;

  /// Nuevo valor de isRequired (opcional)
  final bool? isRequired;

  /// Nuevo valor de isChecked (opcional)
  /// Al cambiar este valor, se actualiza automáticamente el estado de la task
  final bool? isChecked;

  /// Constructor del DTO para actualizar checklist item
  UpdateChecklistItemDto({
    this.description,
    this.isRequired,
    this.isChecked,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  /// 
  /// Solo incluye los campos que no son null.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (description != null) json['description'] = description;
    if (isRequired != null) json['isRequired'] = isRequired;
    if (isChecked != null) json['isChecked'] = isChecked;
    return json;
  }
}
