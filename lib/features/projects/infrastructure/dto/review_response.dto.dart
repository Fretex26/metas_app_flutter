/// DTO que representa la respuesta del backend para una review.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear una review.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class ReviewResponseDto {
  /// Identificador único de la review (UUID)
  final String id;

  /// Identificador del sprint al que pertenece
  final String sprintId;

  /// Identificador del usuario que creó la review
  final String userId;

  /// Porcentaje de progreso calculado automáticamente (0-100)
  final int progressPercentage;

  /// Puntos extra otorgados
  final int extraPoints;

  /// Resumen opcional de la revisión
  final String? summary;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de review
  ReviewResponseDto({
    required this.id,
    required this.sprintId,
    required this.userId,
    required this.progressPercentage,
    required this.extraPoints,
    this.summary,
    required this.createdAt,
  });

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) {
    return ReviewResponseDto(
      id: json['id'] as String,
      sprintId: json['sprintId'] as String,
      userId: json['userId'] as String,
      progressPercentage: json['progressPercentage'] as int,
      extraPoints: json['extraPoints'] as int,
      summary: json['summary'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sprintId': sprintId,
      'userId': userId,
      'progressPercentage': progressPercentage,
      'extraPoints': extraPoints,
      if (summary != null) 'summary': summary,
      'createdAt': createdAt,
    };
  }
}
