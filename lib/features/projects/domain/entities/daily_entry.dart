import 'difficulty.dart';
import 'energy_change.dart';

/// Entidad que representa una Daily Entry (Entrada Diaria) en el dominio de la aplicación.
/// 
/// Una entrada diaria permite a los usuarios documentar:
/// - Reflexiones sobre el trabajo del día anterior
/// - Planificación del trabajo del día actual
/// - Nivel de dificultad experimentado
/// - Cambio en el nivel de energía
/// - Relación requerida con un sprint específico
/// - Relación opcional con una tarea específica
/// 
/// Características principales:
/// - Relación Many-to-One con User (muchas entradas pertenecen a un usuario)
/// - Relación Many-to-One con Sprint (requerida - cada entrada debe pertenecer a un sprint)
/// - Relación opcional Many-to-One con Task (puede estar asociada a una tarea)
/// - Un usuario solo puede tener una entrada diaria por día
class DailyEntry {
  /// Identificador único de la entrada diaria (UUID)
  final String id;

  /// Identificador del usuario que creó la entrada
  final String userId;

  /// Identificador de la tarea relacionada (opcional)
  final String? taskId;

  /// Identificador del sprint relacionado (requerido)
  final String sprintId;

  /// Notas sobre lo realizado ayer (requerido)
  final String notesYesterday;

  /// Notas sobre lo planeado para hoy (requerido)
  final String notesToday;

  /// Nivel de dificultad experimentado (requerido)
  final Difficulty difficulty;

  /// Cambio en el nivel de energía (requerido)
  final EnergyChange energyChange;

  /// Fecha de creación de la entrada
  final DateTime createdAt;

  /// Constructor de la entidad DailyEntry
  DailyEntry({
    required this.id,
    required this.userId,
    this.taskId,
    required this.sprintId,
    required this.notesYesterday,
    required this.notesToday,
    required this.difficulty,
    required this.energyChange,
    required this.createdAt,
  });
}
