import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';

class GetProjectByIdUseCase {
  final ProjectRepository _repository;

  GetProjectByIdUseCase(this._repository);

  Future<Project> call(String id) async {
    return await _repository.getProjectById(id);
  }
}
