import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para eliminar un Sponsored Goal (solo el sponsor dueño).
class DeleteSponsoredGoalUseCase {
  final SponsoredGoalsRepository _repository;

  DeleteSponsoredGoalUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteSponsoredGoal(id);
  }
}
