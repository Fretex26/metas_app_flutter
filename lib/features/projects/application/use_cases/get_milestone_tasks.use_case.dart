import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';

class GetMilestoneTasksUseCase {
  final TaskRepository _repository;

  GetMilestoneTasksUseCase(this._repository);

  Future<List<Task>> call(String milestoneId) async {
    return await _repository.getMilestoneTasks(milestoneId);
  }
}
