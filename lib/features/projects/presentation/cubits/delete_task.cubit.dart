import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_task.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_task.states.dart';

/// Cubit para gestionar el estado de la eliminación de tasks.
class DeleteTaskCubit extends Cubit<DeleteTaskState> {
  final DeleteTaskUseCase _deleteTaskUseCase;

  DeleteTaskCubit({
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _deleteTaskUseCase = deleteTaskUseCase,
        super(DeleteTaskInitial());

  Future<void> deleteTask(String milestoneId, String taskId) async {
    emit(DeleteTaskLoading());
    try {
      await _deleteTaskUseCase(milestoneId, taskId);
      emit(DeleteTaskSuccess());
    } catch (e) {
      emit(DeleteTaskError(e.toString()));
    }
  }
}
