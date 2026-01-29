import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';

/// Caso de uso para obtener los proyectos patrocinados de un usuario.
/// 
/// Este caso de uso encapsula la lógica de negocio para obtener los proyectos
/// patrocinados de un usuario. Solo puede ser ejecutado por sponsors.
/// 
/// Solo retorna proyectos de los sponsored goals del sponsor que hace la petición.
class GetUserSponsoredProjectsUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  GetUserSponsoredProjectsUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener los proyectos patrocinados de un usuario.
  /// 
  /// [userEmail] - Email del usuario del cual obtener los proyectos
  /// 
  /// Retorna una lista de proyectos patrocinados del usuario.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no es sponsor (403)
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<Project>> call(String userEmail) async {
    return await _repository.getUserSponsoredProjects(userEmail);
  }
}
