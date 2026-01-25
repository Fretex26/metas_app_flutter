import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';

/// Caso de uso para crear un nuevo proyecto.
/// 
/// Este caso de uso encapsula la lógica de negocio para crear un proyecto
/// desde el repositorio. Valida que el usuario no exceda el límite de 6 proyectos activos.
class CreateProjectUseCase {
  /// Repositorio de proyectos para acceder a los datos
  final ProjectRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de proyectos inyectado
  CreateProjectUseCase(this._repository);

  /// Ejecuta el caso de uso para crear un proyecto.
  /// 
  /// [dto] - Datos del proyecto a crear, incluyendo la recompensa obligatoria
  /// 
  /// Retorna el proyecto creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El usuario ya tiene 6 proyectos activos (400)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Project> call(CreateProjectDto dto) async {
    return await _repository.createProject(dto);
  }
}
