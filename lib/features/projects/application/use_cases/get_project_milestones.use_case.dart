import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';

class GetProjectMilestonesUseCase {
  final MilestoneRepository _repository;

  GetProjectMilestonesUseCase(this._repository);

  Future<List<Milestone>> call(String projectId) async {
    return await _repository.getProjectMilestones(projectId);
  }
}
