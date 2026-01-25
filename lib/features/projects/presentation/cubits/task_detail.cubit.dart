import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_task_by_id.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.states.dart';

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final GetChecklistItemsUseCase _getChecklistItemsUseCase;

  TaskDetailCubit({
    required GetTaskByIdUseCase getTaskByIdUseCase,
    required GetChecklistItemsUseCase getChecklistItemsUseCase,
  })  : _getTaskByIdUseCase = getTaskByIdUseCase,
        _getChecklistItemsUseCase = getChecklistItemsUseCase,
        super(TaskDetailInitial());

  Future<void> loadTask(String milestoneId, String taskId) async {
    emit(TaskDetailLoading());
    try {
      final results = await Future.wait([
        _getTaskByIdUseCase(milestoneId, taskId),
        _getChecklistItemsUseCase(taskId),
      ]);

      emit(TaskDetailLoaded(
        task: results[0] as Task,
        checklistItems: results[1] as List<ChecklistItem>,
      ));
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  Future<void> refreshTask(String milestoneId, String taskId) async {
    await loadTask(milestoneId, taskId);
  }
}
