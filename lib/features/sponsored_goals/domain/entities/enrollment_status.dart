/// Enum que representa los estados de una inscripción a un Sponsored Goal.
/// 
/// Los estados determinan si un usuario está activo, inactivo o ha completado
/// su participación en un objetivo patrocinado.
enum EnrollmentStatus {
  /// Inscripción activa - el usuario puede trabajar en el proyecto
  active,

  /// Inscripción inactiva - desactivada por el sponsor
  inactive,

  /// Inscripción completada - el proyecto fue completado
  completed,
}

/// Extensión para convertir EnrollmentStatus a string y viceversa.
extension EnrollmentStatusExtension on EnrollmentStatus {
  /// Convierte el enum a su representación en string (para el backend).
  String get value {
    switch (this) {
      case EnrollmentStatus.active:
        return 'ACTIVE';
      case EnrollmentStatus.inactive:
        return 'INACTIVE';
      case EnrollmentStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Crea un EnrollmentStatus desde un string del backend.
  static EnrollmentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return EnrollmentStatus.active;
      case 'INACTIVE':
        return EnrollmentStatus.inactive;
      case 'COMPLETED':
        return EnrollmentStatus.completed;
      default:
        return EnrollmentStatus.active; // Por defecto active
    }
  }
}
