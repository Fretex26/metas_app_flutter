/// Utilidades de validación para formularios de proyectos, milestones y tasks.
/// 
/// Proporciona métodos estáticos para validar campos de formularios según
/// las reglas de negocio del backend.
class ProjectValidators {
  /// Valida el nombre de un proyecto, milestone o task.
  /// 
  /// [value] - Valor a validar
  /// 
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length > 255) {
      return 'El nombre no puede exceder 255 caracteres';
    }
    return null;
  }

  /// Valida el presupuesto de un proyecto.
  /// 
  /// [value] - Valor a validar (puede ser vacío ya que es opcional)
  /// 
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateBudget(String? value) {
    if (value == null || value.isEmpty) return null; // Opcional
    final budget = double.tryParse(value);
    if (budget == null) {
      return 'El presupuesto debe ser un número válido';
    }
    if (budget < 0) {
      return 'El presupuesto no puede ser negativo';
    }
    return null;
  }

  /// Valida la fecha final de un proyecto.
  /// 
  /// [date] - Fecha a validar (puede ser null ya que es opcional)
  /// [startDate] - Fecha de inicio para comparar (opcional)
  /// 
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateFinalDate(DateTime? date, DateTime? startDate) {
    if (date == null) return null; // Opcional
    if (startDate != null && date.isBefore(startDate)) {
      return 'La fecha final debe ser posterior a la fecha de inicio';
    }
    return null;
  }
}

/// Utilidades de validación específicas para tasks.
class TaskValidators {
  /// Valida las fechas de inicio y fin de una task.
  /// 
  /// [startDate] - Fecha de inicio
  /// [endDate] - Fecha de fin
  /// 
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateDates(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Ambas fechas son requeridas';
    }
    if (endDate.isBefore(startDate)) {
      return 'La fecha de fin debe ser posterior a la fecha de inicio';
    }
    return null;
  }

  /// Valida los puntos de incentivo de una task.
  /// 
  /// [value] - Valor a validar (puede ser vacío ya que es opcional)
  /// 
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateIncentivePoints(String? value) {
    if (value == null || value.isEmpty) return null; // Opcional
    final points = int.tryParse(value);
    if (points == null) {
      return 'Los puntos deben ser un número válido';
    }
    if (points < 0) {
      return 'Los puntos no pueden ser negativos';
    }
    return null;
  }
}
