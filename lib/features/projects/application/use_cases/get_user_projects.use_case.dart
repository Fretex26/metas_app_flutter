import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';

/// Caso de uso para obtener todos los proyectos del usuario autenticado.
/// 
/// Este caso de uso encapsula la lógica de negocio para recuperar la lista
/// de proyectos asociados al usuario actual desde el repositorio.
class GetUserProjectsUseCase {
  /// Repositorio de proyectos para acceder a los datos
  final ProjectRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de proyectos inyectado
  GetUserProjectsUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener los proyectos del usuario.
  /// 
  /// Retorna una lista de proyectos del usuario autenticado.
  /// 
  /// Lanza una excepción si hay un error al obtener los proyectos.
  Future<List<Project>> call() async {
    return await _repository.getUserProjects();
  }
}
