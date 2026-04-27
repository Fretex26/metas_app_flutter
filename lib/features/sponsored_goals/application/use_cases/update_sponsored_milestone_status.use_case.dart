import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para actualizar el estado de una milestone patrocinada.
class UpdateSponsoredMilestoneStatusUseCase {
  final SponsoredGoalsRepository _repository;

  UpdateSponsoredMilestoneStatusUseCase(this._repository);

  Future<Milestone> call(String milestoneId, String status) async {
    return _repository.updateSponsoredMilestoneStatus(milestoneId, status);
  }
}
