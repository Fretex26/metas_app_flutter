import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/domain/repositories/retrospective.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';

class CreateRetrospectiveUseCase {
  final RetrospectiveRepository _repository;

  CreateRetrospectiveUseCase(this._repository);

  Future<Retrospective> call(String sprintId, CreateRetrospectiveDto dto) async {
    return await _repository.createRetrospective(sprintId, dto);
  }
}
