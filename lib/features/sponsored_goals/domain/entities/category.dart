/// Entidad que representa una Categoría en el dominio de la aplicación.
/// 
/// Las categorías se utilizan para clasificar y filtrar los Sponsored Goals.
/// Un Sponsored Goal puede tener múltiples categorías asociadas.
class Category {
  /// Identificador único de la categoría (UUID)
  final String id;

  /// Nombre de la categoría
  final String name;

  /// Descripción opcional de la categoría
  final String? description;

  /// Fecha de creación de la categoría
  final DateTime createdAt;

  /// Constructor de la entidad Category
  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });
}
