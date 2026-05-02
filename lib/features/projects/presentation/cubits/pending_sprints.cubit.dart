import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/load_pending_reminders.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.states.dart';

class PendingSprintsCubit extends Cubit<PendingSprintsState> {
  final LoadPendingRemindersUseCase _loadPendingRemindersUseCase;

  PendingSprintsCubit({required LoadPendingRemindersUseCase loadPendingRemindersUseCase})
      : _loadPendingRemindersUseCase = loadPendingRemindersUseCase,
        super(PendingSprintsInitial());

  /// Carga review/retrospectiva pendientes (API) y sprints activos sin daily hoy.
  Future<void> loadPendingSprints() async {
    emit(PendingSprintsLoading());
    try {
      final pendingSprints = await _loadPendingRemindersUseCase();
      emit(PendingSprintsLoaded(pendingSprints));
    } catch (e) {
      emit(PendingSprintsError(e.toString()));
    }
  }

  /// Refresca la lista de sprints pendientes
  void refresh() {
    loadPendingSprints();
  }
}
