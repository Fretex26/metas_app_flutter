import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';

class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<Task> call(String milestoneId, CreateTaskDto dto) async {
    return await _repository.createTask(milestoneId, dto);
  }
}
