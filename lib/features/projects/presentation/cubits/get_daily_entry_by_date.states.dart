import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';

/// Estados del cubit para obtener una entrada diaria por fecha.
/// 
/// Define los diferentes estados que puede tener el proceso de obtención
/// de una entrada diaria por fecha.
abstract class GetDailyEntryByDateState {}

/// Estado inicial del cubit (antes de intentar obtener la entrada)
class GetDailyEntryByDateInitial extends GetDailyEntryByDateState {}

/// Estado de carga (mientras se está obteniendo la entrada diaria)
class GetDailyEntryByDateLoading extends GetDailyEntryByDateState {}

/// Estado de éxito (cuando se obtuvo la entrada diaria correctamente o no existe)
class GetDailyEntryByDateLoaded extends GetDailyEntryByDateState {
  /// Entrada diaria encontrada, o null si no existe para esa fecha
  final DailyEntry? dailyEntry;

  GetDailyEntryByDateLoaded(this.dailyEntry);
}

/// Estado de error (cuando ocurrió un error al obtener la entrada diaria)
class GetDailyEntryByDateError extends GetDailyEntryByDateState {
  /// Mensaje de error
  final String message;

  GetDailyEntryByDateError(this.message);
}
