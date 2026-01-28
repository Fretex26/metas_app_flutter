import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_daily_entry.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_daily_entry.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_daily_entry.states.dart';

/// Cubit para manejar la creación de entradas diarias.
/// 
/// Gestiona el estado del proceso de creación de una entrada diaria,
/// desde el estado inicial hasta el éxito o error.
class CreateDailyEntryCubit extends Cubit<CreateDailyEntryState> {
  /// Use case para crear una entrada diaria
  final CreateDailyEntryUseCase _createDailyEntryUseCase;

  /// Constructor del cubit
  /// 
  /// [createDailyEntryUseCase] - Use case requerido para crear entradas diarias
  CreateDailyEntryCubit({
    required CreateDailyEntryUseCase createDailyEntryUseCase,
  })  : _createDailyEntryUseCase = createDailyEntryUseCase,
        super(CreateDailyEntryInitial());

  /// Crea una nueva entrada diaria.
  /// 
  /// [dto] - Datos de la entrada diaria a crear
  /// 
  /// Emite estados de carga, éxito o error según el resultado de la operación.
  Future<void> createDailyEntry(CreateDailyEntryDto dto) async {
    emit(CreateDailyEntryLoading());
    try {
      final dailyEntry = await _createDailyEntryUseCase(dto);
      emit(CreateDailyEntrySuccess(dailyEntry.id));
    } catch (e) {
      // Extraer el mensaje de la excepción sin el prefijo "Exception: "
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11); // Remover "Exception: "
      }
      emit(CreateDailyEntryError(errorMessage));
    }
  }
}
