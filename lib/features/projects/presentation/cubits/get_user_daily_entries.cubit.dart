import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_daily_entries.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_user_daily_entries.states.dart';

/// Cubit para manejar la obtención de las entradas diarias del usuario.
/// 
/// Gestiona el estado del proceso de obtención de entradas diarias,
/// desde el estado inicial hasta el éxito o error.
class GetUserDailyEntriesCubit extends Cubit<GetUserDailyEntriesState> {
  /// Use case para obtener las entradas diarias del usuario
  final GetUserDailyEntriesUseCase _getUserDailyEntriesUseCase;

  /// Constructor del cubit
  /// 
  /// [getUserDailyEntriesUseCase] - Use case requerido para obtener entradas diarias
  GetUserDailyEntriesCubit({
    required GetUserDailyEntriesUseCase getUserDailyEntriesUseCase,
  })  : _getUserDailyEntriesUseCase = getUserDailyEntriesUseCase,
        super(GetUserDailyEntriesInitial());

  /// Carga las entradas diarias del usuario.
  /// 
  /// Emite estados de carga, éxito o error según el resultado de la operación.
  Future<void> loadDailyEntries() async {
    emit(GetUserDailyEntriesLoading());
    try {
      final dailyEntries = await _getUserDailyEntriesUseCase();
      emit(GetUserDailyEntriesLoaded(dailyEntries));
    } catch (e) {
      emit(GetUserDailyEntriesError(e.toString()));
    }
  }

  /// Refresca las entradas diarias del usuario.
  /// 
  /// Vuelve a cargar las entradas diarias desde el servidor.
  void refresh() {
    loadDailyEntries();
  }
}
