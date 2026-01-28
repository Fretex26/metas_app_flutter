/// Enum que representa el nivel de dificultad de una entrada diaria.
/// 
/// Se utiliza para clasificar qué tan difícil fue el trabajo del día.
enum Difficulty {
  /// Dificultad baja
  low,
  
  /// Dificultad media
  medium,
  
  /// Dificultad alta
  high;

  /// Obtiene el nombre para mostrar del nivel de dificultad.
  String get displayName {
    switch (this) {
      case Difficulty.low:
        return 'Baja';
      case Difficulty.medium:
        return 'Media';
      case Difficulty.high:
        return 'Alta';
    }
  }

  /// Convierte un string a un valor de Difficulty.
  /// 
  /// [value] - String que representa el nombre del enum (ej: "low", "medium", "high")
  /// 
  /// Retorna el valor correspondiente de Difficulty, o medium por defecto si no se encuentra.
  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Difficulty.medium,
    );
  }
}
