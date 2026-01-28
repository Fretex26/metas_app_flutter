import '../../domain/entities/difficulty.dart';
import '../../domain/entities/energy_change.dart';

/// DTO para crear una nueva entrada diaria.
/// 
/// Contiene los campos necesarios para crear una daily entry.
/// El campo energyChange siempre se envía como "increased" ya que
/// cada vez que el usuario completa un daily, como recompensa se incrementa la energía.
/// 
/// **Importante**: El sprintId es requerido. Solo se permite una entrada diaria por día por usuario.
class CreateDailyEntryDto {
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

  /// Constructor del DTO para crear entrada diaria
  /// 
  /// Nota: energyChange no se incluye como parámetro porque siempre se envía como "increased"
  /// según los requisitos del negocio (recompensa por completar el daily).
  /// 
  /// [sprintId] - Requerido: Identificador del sprint al que pertenece la entrada diaria
  CreateDailyEntryDto({
    this.taskId,
    required this.sprintId,
    required this.notesYesterday,
    required this.notesToday,
    required this.difficulty,
  });

  /// Convierte el DTO a JSON para enviarlo al backend.
  /// 
  /// Siempre incluye energyChange como "increased" según los requisitos.
  /// El sprintId siempre se incluye porque es requerido.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'sprintId': sprintId, // Siempre incluido porque es requerido
      'notesYesterday': notesYesterday,
      'notesToday': notesToday,
      'difficulty': difficulty.name,
      // Siempre enviar energyChange como "increased" (recompensa por completar el daily)
      'energyChange': EnergyChange.increased.name,
    };

    if (taskId != null) {
      json['taskId'] = taskId;
    }

    return json;
  }

  /// Valida que el DTO tenga todos los campos requeridos.
  bool get isValid {
    return sprintId.isNotEmpty &&
        notesYesterday.isNotEmpty &&
        notesToday.isNotEmpty;
  }
}
