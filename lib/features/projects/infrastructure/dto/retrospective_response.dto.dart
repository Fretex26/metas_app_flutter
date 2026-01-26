/// DTO que representa la respuesta del backend para una retrospectiva.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear una retrospectiva.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class RetrospectiveResponseDto {
  /// Identificador único de la retrospectiva (UUID)
  final String id;

  /// Identificador del sprint al que pertenece
  final String sprintId;

  /// Identificador del usuario que creó la retrospectiva
  final String userId;

  /// Lo que salió bien durante el sprint
  final String whatWentWell;

  /// Lo que salió mal durante el sprint
  final String whatWentWrong;

  /// Mejoras propuestas para futuros sprints (opcional)
  final String? improvements;

  /// Indica si la retrospectiva es pública (true) o privada (false)
  final bool isPublic;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de retrospectiva
  RetrospectiveResponseDto({
    required this.id,
    required this.sprintId,
    required this.userId,
    required this.whatWentWell,
    required this.whatWentWrong,
    this.improvements,
    required this.isPublic,
    required this.createdAt,
  });

  factory RetrospectiveResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrospectiveResponseDto(
      id: json['id'] as String,
      sprintId: json['sprintId'] as String,
      userId: json['userId'] as String,
      whatWentWell: json['whatWentWell'] as String,
      whatWentWrong: json['whatWentWrong'] as String,
      improvements: json['improvements'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sprintId': sprintId,
      'userId': userId,
      'whatWentWell': whatWentWell,
      'whatWentWrong': whatWentWrong,
      if (improvements != null) 'improvements': improvements,
      'isPublic': isPublic,
      'createdAt': createdAt,
    };
  }
}
