/// Entidad que representa un Sprint en el dominio de la aplicación.
/// 
/// Un sprint es un período de trabajo dentro de un milestone, típicamente de 1 a 4 semanas.
/// Los sprints permiten dividir un milestone en períodos de trabajo más pequeños y manejables.
/// 
/// Un sprint puede contener múltiples tasks y puede tener asociadas reviews y retrospectivas
/// (aunque estas funcionalidades se implementarán posteriormente).
/// 
/// Validaciones importantes:
/// - La fecha de fin debe ser posterior a la fecha de inicio
/// - El período no debe exceder 4 semanas (28 días)
/// - El sprint debe pertenecer a un milestone válido
class Sprint {
  /// Identificador único del sprint (UUID)
  final String id;

  /// Identificador del milestone al que pertenece este sprint
  final String milestoneId;

  /// Nombre del sprint (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del sprint
  final String? description;

  /// Criterios de aceptación del sprint (objeto JSON opcional)
  /// Formato: { "criterio1": "descripción", "criterio2": "descripción" }
  final Map<String, dynamic>? acceptanceCriteria;

  /// Fecha de inicio del sprint
  final DateTime startDate;

  /// Fecha de fin del sprint (debe ser posterior a startDate)
  final DateTime endDate;

  /// Recursos disponibles para el sprint (objeto JSON opcional)
  /// Formato: { "recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios para el sprint (objeto JSON opcional)
  /// Formato: { "recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// Fecha de creación del sprint
  final DateTime createdAt;

  /// Constructor de la entidad Sprint
  Sprint({
    required this.id,
    required this.milestoneId,
    required this.name,
    this.description,
    this.acceptanceCriteria,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    required this.createdAt,
  });

  /// Calcula la duración del sprint en días
  /// 
  /// Retorna el número de días entre startDate y endDate (inclusive)
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Verifica si el sprint está dentro del período válido (máximo 28 días)
  /// 
  /// Retorna true si la duración es menor o igual a 28 días
  bool get isValidDuration {
    return durationInDays <= 28;
  }
}
