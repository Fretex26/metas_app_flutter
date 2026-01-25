/// DTO que representa la respuesta del backend para una recompensa (Reward).
/// 
/// Contiene todos los campos que el backend retorna al obtener una recompensa.
class RewardResponseDto {
  /// Identificador único de la recompensa (UUID)
  final String id;

  /// Nombre de la recompensa
  final String name;

  /// Descripción opcional de la recompensa
  final String? description;

  /// Instrucciones para reclamar la recompensa
  final String? claimInstructions;

  /// URL válida para reclamar la recompensa
  final String? claimLink;

  /// Constructor del DTO de respuesta de recompensa
  RewardResponseDto({
    required this.id,
    required this.name,
    this.description,
    this.claimInstructions,
    this.claimLink,
  });

  /// Crea una instancia de RewardResponseDto desde un JSON
  factory RewardResponseDto.fromJson(Map<String, dynamic> json) {
    return RewardResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      claimInstructions: json['claimInstructions'] as String?,
      claimLink: json['claimLink'] as String?,
    );
  }

  /// Convierte el DTO a formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (claimInstructions != null) 'claimInstructions': claimInstructions,
      if (claimLink != null) 'claimLink': claimLink,
    };
  }
}
