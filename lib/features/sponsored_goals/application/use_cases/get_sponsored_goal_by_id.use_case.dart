import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para obtener un Sponsored Goal por ID (solo si pertenece al sponsor).
class GetSponsoredGoalByIdUseCase {
  final SponsoredGoalsRepository _repository;

  GetSponsoredGoalByIdUseCase(this._repository);

  Future<SponsoredGoal> call(String id) async {
    return await _repository.getSponsoredGoalById(id);
  }
}
