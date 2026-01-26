/// Utilidades para formatear fechas.
class DateFormatter {
  /// Formatea una fecha en formato DD/MM/YYYY.
  /// 
  /// [date] - Fecha a formatear
  /// 
  /// Retorna la fecha formateada como string.
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formatea un rango de fechas.
  /// 
  /// [startDate] - Fecha de inicio
  /// [endDate] - Fecha de fin
  /// 
  /// Retorna el rango formateado como string (ej: "01/01/2024 - 31/01/2024").
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }
}
