import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/domain/repositories/retrospective.repository.dart';

class GetSprintRetrospectiveUseCase {
  final RetrospectiveRepository _repository;

  GetSprintRetrospectiveUseCase(this._repository);

  Future<Retrospective?> call(String sprintId) async {
    return await _repository.getSprintRetrospective(sprintId);
  }
}
