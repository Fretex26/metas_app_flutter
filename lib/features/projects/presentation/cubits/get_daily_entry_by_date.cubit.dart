import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_daily_entry_by_date.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_daily_entry_by_date.states.dart';

/// Cubit para manejar la obtención de una entrada diaria por fecha.
/// 
/// Gestiona el estado del proceso de obtención de una entrada diaria por fecha,
/// desde el estado inicial hasta el éxito o error.
class GetDailyEntryByDateCubit extends Cubit<GetDailyEntryByDateState> {
  /// Use case para obtener una entrada diaria por fecha
  final GetDailyEntryByDateUseCase _getDailyEntryByDateUseCase;

  /// Constructor del cubit
  /// 
  /// [getDailyEntryByDateUseCase] - Use case requerido para obtener entrada diaria por fecha
  GetDailyEntryByDateCubit({
    required GetDailyEntryByDateUseCase getDailyEntryByDateUseCase,
  })  : _getDailyEntryByDateUseCase = getDailyEntryByDateUseCase,
        super(GetDailyEntryByDateInitial());

  /// Carga la entrada diaria para una fecha y un sprint concretos.
  ///
  /// [date] - Fecha para buscar la entrada diaria.
  /// [sprintId] - UUID del sprint (obligatorio). Cada daily entry pertenece a un sprint.
  ///
  /// Emite estados de carga, éxito o error según el resultado de la operación.
  /// Si no existe una entrada para esa fecha en ese sprint, emite GetDailyEntryByDateLoaded con null.
  Future<void> loadDailyEntryByDate(DateTime date, String sprintId) async {
    emit(GetDailyEntryByDateLoading());
    try {
      final dailyEntry = await _getDailyEntryByDateUseCase(date, sprintId);
      emit(GetDailyEntryByDateLoaded(dailyEntry));
    } catch (e) {
      emit(GetDailyEntryByDateError(e.toString()));
    }
  }

  /// Refresca la entrada diaria para una fecha y un sprint concretos.
  ///
  /// [date] - Fecha para buscar la entrada diaria.
  /// [sprintId] - UUID del sprint (obligatorio).
  void refresh(DateTime date, String sprintId) {
    loadDailyEntryByDate(date, sprintId);
  }
}
