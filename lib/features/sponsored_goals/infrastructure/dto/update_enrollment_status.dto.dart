/// DTO para actualizar el estado de una inscripción a un Sponsored Goal.
/// 
/// Solo permite cambiar el estado de la inscripción (ACTIVE, INACTIVE, COMPLETED).
class UpdateEnrollmentStatusDto {
  /// Nuevo estado de la inscripción
  /// Valores posibles: "ACTIVE", "INACTIVE", "COMPLETED"
  final String status;

  /// Constructor del DTO para actualizar estado de inscripción
  UpdateEnrollmentStatusDto({
    required this.status,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
