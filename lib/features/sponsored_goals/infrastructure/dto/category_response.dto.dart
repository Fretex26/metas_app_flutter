/// DTO que representa la respuesta del backend para una categoría.
/// 
/// Contiene todos los campos que el backend retorna al obtener una categoría.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class CategoryResponseDto {
  /// Identificador único de la categoría (UUID)
  final String id;

  /// Nombre de la categoría
  final String name;

  /// Descripción opcional de la categoría
  final String? description;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de categoría
  CategoryResponseDto({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) {
    return CategoryResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convierte el DTO a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'createdAt': createdAt,
    };
  }
}
