/// Enum que representa el cambio en el nivel de energía de una entrada diaria.
/// 
/// Se utiliza para rastrear cómo cambió el nivel de energía del usuario.
enum EnergyChange {
  /// Energía aumentada
  increased,
  
  /// Energía estable
  stable,
  
  /// Energía disminuida
  decreased;

  /// Obtiene el nombre para mostrar del cambio de energía.
  String get displayName {
    switch (this) {
      case EnergyChange.increased:
        return 'Aumentada';
      case EnergyChange.stable:
        return 'Estable';
      case EnergyChange.decreased:
        return 'Disminuida';
    }
  }

  /// Convierte un string a un valor de EnergyChange.
  /// 
  /// [value] - String que representa el nombre del enum (ej: "increased", "stable", "decreased")
  /// 
  /// Retorna el valor correspondiente de EnergyChange, o stable por defecto si no se encuentra.
  static EnergyChange fromString(String value) {
    return EnergyChange.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EnergyChange.stable,
    );
  }
}
