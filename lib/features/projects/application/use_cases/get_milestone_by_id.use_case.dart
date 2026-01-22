import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';

class GetMilestoneByIdUseCase {
  final MilestoneRepository _repository;

  GetMilestoneByIdUseCase(this._repository);

  Future<Milestone> call(String projectId, String milestoneId) async {
    return await _repository.getMilestoneById(projectId, milestoneId);
  }
}
