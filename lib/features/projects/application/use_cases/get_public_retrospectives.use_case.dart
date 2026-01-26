import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/domain/repositories/retrospective.repository.dart';

class GetPublicRetrospectivesUseCase {
  final RetrospectiveRepository _repository;

  GetPublicRetrospectivesUseCase(this._repository);

  Future<List<Retrospective>> call() async {
    return await _repository.getPublicRetrospectives();
  }
}
