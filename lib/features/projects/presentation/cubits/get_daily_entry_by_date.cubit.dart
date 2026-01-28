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

  /// Carga la entrada diaria para una fecha específica.
  /// 
  /// [date] - Fecha para buscar la entrada diaria
  /// 
  /// Emite estados de carga, éxito o error según el resultado de la operación.
  /// Si no existe una entrada para esa fecha, emite GetDailyEntryByDateLoaded con null.
  Future<void> loadDailyEntryByDate(DateTime date) async {
    emit(GetDailyEntryByDateLoading());
    try {
      final dailyEntry = await _getDailyEntryByDateUseCase(date);
      emit(GetDailyEntryByDateLoaded(dailyEntry));
    } catch (e) {
      emit(GetDailyEntryByDateError(e.toString()));
    }
  }

  /// Refresca la entrada diaria para una fecha específica.
  /// 
  /// [date] - Fecha para buscar la entrada diaria
  /// 
  /// Vuelve a cargar la entrada diaria desde el servidor.
  void refresh(DateTime date) {
    loadDailyEntryByDate(date);
  }
}
