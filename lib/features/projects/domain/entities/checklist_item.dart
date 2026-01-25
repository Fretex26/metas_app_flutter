/// Entidad que representa un Checklist Item (Item de Lista de Verificación) en el dominio.
/// 
/// Un checklist item es un elemento individual dentro de una task que puede ser marcado como completado.
/// Los items pueden ser requeridos o opcionales.
/// 
/// Cuando se marca o desmarca un checklist item, el estado de la task asociada se actualiza automáticamente.
class ChecklistItem {
  /// Identificador único del checklist item (UUID)
  final String id;

  /// Identificador de la task a la que pertenece este item
  final String? taskId;

  /// Descripción del checklist item (requerida)
  final String description;

  /// Indica si el item es requerido para completar la task
  /// Si es true, todos los items requeridos deben estar marcados para que la task se complete
  final bool isRequired;

  /// Indica si el item ha sido marcado como completado
  final bool isChecked;

  /// Fecha de creación del checklist item
  final DateTime createdAt;

  /// Constructor de la entidad ChecklistItem
  ChecklistItem({
    required this.id,
    this.taskId,
    required this.description,
    required this.isRequired,
    required this.isChecked,
    required this.createdAt,
  });
}
