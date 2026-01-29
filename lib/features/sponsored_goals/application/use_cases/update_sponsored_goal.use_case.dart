import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_sponsored_goal.dto.dart';

/// Caso de uso para actualizar un Sponsored Goal (PATCH parcial). Solo el sponsor dueño.
class UpdateSponsoredGoalUseCase {
  final SponsoredGoalsRepository _repository;

  UpdateSponsoredGoalUseCase(this._repository);

  Future<SponsoredGoal> call(String id, UpdateSponsoredGoalDto dto) async {
    return await _repository.updateSponsoredGoal(id, dto);
  }
}
