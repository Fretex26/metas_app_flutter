import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';

class CreateMilestoneUseCase {
  final MilestoneRepository _repository;

  CreateMilestoneUseCase(this._repository);

  Future<Milestone> call(String projectId, CreateMilestoneDto dto) async {
    return await _repository.createMilestone(projectId, dto);
  }
}
