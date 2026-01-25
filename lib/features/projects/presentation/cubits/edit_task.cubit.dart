import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/update_task.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_task.states.dart';

/// Cubit para gestionar el estado de la edición de tasks.
class EditTaskCubit extends Cubit<EditTaskState> {
  final UpdateTaskUseCase _updateTaskUseCase;

  EditTaskCubit({
    required UpdateTaskUseCase updateTaskUseCase,
  })  : _updateTaskUseCase = updateTaskUseCase,
        super(EditTaskInitial());

  Future<void> updateTask(String milestoneId, String id, UpdateTaskDto dto) async {
    emit(EditTaskLoading());
    try {
      final updatedTask = await _updateTaskUseCase(milestoneId, id, dto);
      emit(EditTaskSuccess(updatedTask));
    } catch (e) {
      emit(EditTaskError(e.toString()));
    }
  }
}
