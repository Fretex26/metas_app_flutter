/// DTO que representa la respuesta del backend para una inscripción a un Sponsored Goal.
/// 
/// Contiene todos los campos que el backend retorna al inscribirse o actualizar
/// el estado de una inscripción. Las fechas vienen como strings en formato ISO.
class SponsorEnrollmentResponseDto {
  /// Identificador único de la inscripción (UUID)
  final String id;

  /// Identificador del sponsored goal al que se inscribió
  final String sponsoredGoalId;

  /// Identificador del usuario inscrito
  final String userId;

  /// Estado actual de la inscripción (string del backend: ACTIVE, INACTIVE, COMPLETED)
  final String status;

  /// Fecha en que el usuario se inscribió en formato ISO string
  final String enrolledAt;

  /// Constructor del DTO de respuesta de inscripción
  SponsorEnrollmentResponseDto({
    required this.id,
    required this.sponsoredGoalId,
    required this.userId,
    required this.status,
    required this.enrolledAt,
  });

  factory SponsorEnrollmentResponseDto.fromJson(Map<String, dynamic> json) {
    return SponsorEnrollmentResponseDto(
      id: json['id'] as String,
      sponsoredGoalId: json['sponsoredGoalId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      enrolledAt: json['enrolledAt'] as String,
    );
  }

  /// Convierte el DTO a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsoredGoalId': sponsoredGoalId,
      'userId': userId,
      'status': status,
      'enrolledAt': enrolledAt,
    };
  }
}
