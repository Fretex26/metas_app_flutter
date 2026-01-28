import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';

/// Estados del cubit para obtener las entradas diarias del usuario.
/// 
/// Define los diferentes estados que puede tener el proceso de obtención
/// de las entradas diarias del usuario.
abstract class GetUserDailyEntriesState {}

/// Estado inicial del cubit (antes de intentar obtener las entradas)
class GetUserDailyEntriesInitial extends GetUserDailyEntriesState {}

/// Estado de carga (mientras se están obteniendo las entradas diarias)
class GetUserDailyEntriesLoading extends GetUserDailyEntriesState {}

/// Estado de éxito (cuando se obtuvieron las entradas diarias correctamente)
class GetUserDailyEntriesLoaded extends GetUserDailyEntriesState {
  /// Lista de entradas diarias del usuario
  final List<DailyEntry> dailyEntries;

  GetUserDailyEntriesLoaded(this.dailyEntries);
}

/// Estado de error (cuando ocurrió un error al obtener las entradas diarias)
class GetUserDailyEntriesError extends GetUserDailyEntriesState {
  /// Mensaje de error
  final String message;

  GetUserDailyEntriesError(this.message);
}
