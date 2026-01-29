import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para listar los Sponsored Goals del sponsor autenticado.
/// 
/// Llama a GET /api/sponsored-goals. Solo retorna objetivos creados por el sponsor.
class GetMySponsoredGoalsUseCase {
  final SponsoredGoalsRepository _repository;

  GetMySponsoredGoalsUseCase(this._repository);

  Future<List<SponsoredGoal>> call() async {
    return await _repository.listSponsorSponsoredGoals();
  }
}
