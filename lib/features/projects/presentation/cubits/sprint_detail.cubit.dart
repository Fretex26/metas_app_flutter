import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_sprint_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_sprint_tasks.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/sprint_detail.states.dart';

/// Cubit para manejar el detalle de un sprint.
/// 
/// Gestiona la carga del sprint y sus tasks asociadas.
class SprintDetailCubit extends Cubit<SprintDetailState> {
  final GetSprintByIdUseCase _getSprintByIdUseCase;
  final GetSprintTasksUseCase _getSprintTasksUseCase;

  SprintDetailCubit({
    required GetSprintByIdUseCase getSprintByIdUseCase,
    required GetSprintTasksUseCase getSprintTasksUseCase,
  })  : _getSprintByIdUseCase = getSprintByIdUseCase,
        _getSprintTasksUseCase = getSprintTasksUseCase,
        super(SprintDetailInitial());

  /// Carga el sprint y sus tasks asociadas.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Emite estados:
  /// - SprintDetailLoading mientras se cargan los datos
  /// - SprintDetailLoaded con el sprint y sus tasks
  /// - SprintDetailError si ocurre un error
  Future<void> loadSprint(String milestoneId, String sprintId) async {
    emit(SprintDetailLoading());
    try {
      final sprint = await _getSprintByIdUseCase(milestoneId, sprintId);
      final tasks = await _getSprintTasksUseCase(milestoneId, sprintId);

      emit(SprintDetailLoaded(
        sprint: sprint,
        tasks: tasks,
      ));
    } catch (e) {
      emit(SprintDetailError(e.toString()));
    }
  }

  /// Recarga el sprint y sus tasks.
  /// 
  /// Útil para actualizar después de crear/editar/eliminar tasks.
  Future<void> refresh(String milestoneId, String sprintId) async {
    await loadSprint(milestoneId, sprintId);
  }
}
