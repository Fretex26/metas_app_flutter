import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository _repository;

  GetTaskByIdUseCase(this._repository);

  Future<Task> call(String milestoneId, String taskId) async {
    return await _repository.getTaskById(milestoneId, taskId);
  }
}
