/// Enum que representa los métodos de verificación disponibles para un Sponsored Goal.
/// 
/// Los métodos de verificación determinan cómo el sponsor puede validar
/// que un usuario ha completado un milestone.
enum VerificationMethod {
  /// Verificación por código QR
  qr,

  /// Verificación por checklist
  checklist,

  /// Verificación manual por el sponsor
  manual,

  /// Verificación por API externa
  externalApi,
}

/// Extensión para convertir VerificationMethod a string y viceversa.
extension VerificationMethodExtension on VerificationMethod {
  /// Convierte el enum a su representación en string (para el backend).
  String get value {
    switch (this) {
      case VerificationMethod.qr:
        return 'qr';
      case VerificationMethod.checklist:
        return 'checklist';
      case VerificationMethod.manual:
        return 'manual';
      case VerificationMethod.externalApi:
        return 'external_api';
    }
  }

  /// Crea un VerificationMethod desde un string del backend.
  static VerificationMethod fromString(String value) {
    switch (value) {
      case 'qr':
        return VerificationMethod.qr;
      case 'checklist':
        return VerificationMethod.checklist;
      case 'manual':
        return VerificationMethod.manual;
      case 'external_api':
        return VerificationMethod.externalApi;
      default:
        return VerificationMethod.manual; // Por defecto manual
    }
  }
}
