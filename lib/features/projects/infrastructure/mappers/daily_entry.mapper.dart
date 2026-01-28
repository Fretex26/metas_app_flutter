import '../../domain/entities/daily_entry.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/energy_change.dart';
import '../dto/daily_entry_response.dto.dart';

/// Extensión para mapear [DailyEntryResponseDto] a la entidad de dominio [DailyEntry].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime y strings de enum a valores de enum.
extension DailyEntryResponseDtoMapper on DailyEntryResponseDto {
  /// Convierte el DTO de respuesta a una entidad DailyEntry del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// - Convierte strings de enum a valores de Difficulty y EnergyChange
  /// 
  /// Retorna una instancia de [DailyEntry] con todos los datos mapeados.
  DailyEntry toDomain() {
    return DailyEntry(
      id: id,
      userId: userId,
      taskId: taskId,
      sprintId: sprintId,
      notesYesterday: notesYesterday,
      notesToday: notesToday,
      difficulty: Difficulty.fromString(difficulty),
      energyChange: EnergyChange.fromString(energyChange),
      createdAt: DateTime.parse(createdAt),
    );
  }
}
