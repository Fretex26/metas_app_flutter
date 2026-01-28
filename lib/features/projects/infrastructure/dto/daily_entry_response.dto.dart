import '../../domain/entities/difficulty.dart';
import '../../domain/entities/energy_change.dart';

/// DTO que representa la respuesta del backend para una entrada diaria.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear una daily entry.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class DailyEntryResponseDto {
  /// Identificador único de la entrada diaria (UUID)
  final String id;

  /// Identificador del usuario que creó la entrada
  final String userId;

  /// Identificador de la tarea relacionada (opcional)
  final String? taskId;

  /// Identificador del sprint relacionado (requerido)
  final String sprintId;

  /// Notas sobre lo realizado ayer
  final String notesYesterday;

  /// Notas sobre lo planeado para hoy
  final String notesToday;

  /// Nivel de dificultad experimentado
  final String difficulty;

  /// Cambio en el nivel de energía
  final String energyChange;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de entrada diaria
  DailyEntryResponseDto({
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

  /// Crea una instancia de DailyEntryResponseDto desde un JSON.
  factory DailyEntryResponseDto.fromJson(Map<String, dynamic> json) {
    return DailyEntryResponseDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String?,
      sprintId: json['sprintId'] as String, // Requerido, no nullable
      notesYesterday: json['notesYesterday'] as String,
      notesToday: json['notesToday'] as String,
      difficulty: json['difficulty'] as String,
      energyChange: json['energyChange'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convierte el DTO a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      if (taskId != null) 'taskId': taskId,
      'sprintId': sprintId, // Siempre incluido porque es requerido
      'notesYesterday': notesYesterday,
      'notesToday': notesToday,
      'difficulty': difficulty,
      'energyChange': energyChange,
      'createdAt': createdAt,
    };
  }
}
