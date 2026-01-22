import 'package:metas_app/features/projects/domain/entities/project_progress.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';

class GetProjectProgressUseCase {
  final ProjectRepository _repository;

  GetProjectProgressUseCase(this._repository);

  Future<ProjectProgress> call(String id) async {
    return await _repository.getProjectProgress(id);
  }
}
