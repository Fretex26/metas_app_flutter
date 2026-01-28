import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_pending_sprints.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.states.dart';

class PendingSprintsCubit extends Cubit<PendingSprintsState> {
  final GetPendingSprintsUseCase _getPendingSprintsUseCase;

  PendingSprintsCubit({required GetPendingSprintsUseCase getPendingSprintsUseCase})
      : _getPendingSprintsUseCase = getPendingSprintsUseCase,
        super(PendingSprintsInitial());

  /// Carga los sprints pendientes de review o retrospectiva
  Future<void> loadPendingSprints() async {
    emit(PendingSprintsLoading());
    try {
      final pendingSprints = await _getPendingSprintsUseCase();
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
