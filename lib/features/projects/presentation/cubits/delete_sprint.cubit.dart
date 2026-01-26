import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_sprint.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_sprint.states.dart';

/// Cubit para manejar la eliminación de sprints.
/// 
/// Gestiona el estado del proceso de eliminación de un sprint.
class DeleteSprintCubit extends Cubit<DeleteSprintState> {
  final DeleteSprintUseCase _deleteSprintUseCase;

  DeleteSprintCubit({required DeleteSprintUseCase deleteSprintUseCase})
      : _deleteSprintUseCase = deleteSprintUseCase,
        super(DeleteSprintInitial());

  /// Elimina un sprint existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada:
  /// - Review asociada (si existe)
  /// - Retrospective asociada (si existe)
  /// - DailyEntries relacionados
  /// - Las tasks NO se eliminan, solo quedan con sprintId = null
  /// 
  /// Emite estados:
  /// - DeleteSprintLoading mientras se procesa
  /// - DeleteSprintSuccess cuando se elimina correctamente
  /// - DeleteSprintError si ocurre un error
  Future<void> deleteSprint(String milestoneId, String sprintId) async {
    emit(DeleteSprintLoading());
    try {
      await _deleteSprintUseCase(milestoneId, sprintId);
      emit(DeleteSprintSuccess());
    } catch (e) {
      emit(DeleteSprintError(e.toString()));
    }
  }
}
