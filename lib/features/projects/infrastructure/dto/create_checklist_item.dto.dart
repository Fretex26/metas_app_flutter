/// DTO para crear un nuevo checklist item dentro de una task.
/// 
/// Contiene los datos necesarios para crear un item de lista de verificación.
/// Al crear o actualizar un checklist item, el estado de la task se actualiza
/// automáticamente según las reglas de dependencias.
class CreateChecklistItemDto {
  /// Descripción del checklist item (requerida)
  final String description;

  /// Indica si el item es requerido para completar la task (por defecto: false)
  final bool isRequired;

  /// Indica si el item está marcado como completado (por defecto: false)
  final bool isChecked;

  /// Constructor del DTO para crear checklist item
  CreateChecklistItemDto({
    required this.description,
    this.isRequired = false,
    this.isChecked = false,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'isRequired': isRequired,
      'isChecked': isChecked,
    };
  }
}
