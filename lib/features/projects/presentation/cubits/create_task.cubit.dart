import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_task.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.states.dart';

class CreateTaskCubit extends Cubit<CreateTaskState> {
  final CreateTaskUseCase _createTaskUseCase;

  CreateTaskCubit({required CreateTaskUseCase createTaskUseCase})
      : _createTaskUseCase = createTaskUseCase,
        super(CreateTaskInitial());

  Future<void> createTask(String milestoneId, CreateTaskDto dto) async {
    emit(CreateTaskLoading());
    try {
      final task = await _createTaskUseCase(milestoneId, dto);
      emit(CreateTaskSuccess(task.id));
    } catch (e) {
      emit(CreateTaskError(e.toString()));
    }
  }
}
