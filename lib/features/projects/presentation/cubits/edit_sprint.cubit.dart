import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/update_sprint.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_sprint.states.dart';

/// Cubit para manejar la edición de sprints.
/// 
/// Gestiona el estado del proceso de actualización de un sprint.
class EditSprintCubit extends Cubit<EditSprintState> {
  final UpdateSprintUseCase _updateSprintUseCase;

  EditSprintCubit({required UpdateSprintUseCase updateSprintUseCase})
      : _updateSprintUseCase = updateSprintUseCase,
        super(EditSprintInitial());

  /// Actualiza un sprint existente.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos a actualizar (todos los campos son opcionales)
  /// 
  /// Emite estados:
  /// - EditSprintLoading mientras se procesa
  /// - EditSprintSuccess cuando se actualiza correctamente
  /// - EditSprintError si ocurre un error
  Future<void> updateSprint(String milestoneId, String sprintId, UpdateSprintDto dto) async {
    emit(EditSprintLoading());
    try {
      await _updateSprintUseCase(milestoneId, sprintId, dto);
      emit(EditSprintSuccess());
    } catch (e) {
      emit(EditSprintError(e.toString()));
    }
  }
}
