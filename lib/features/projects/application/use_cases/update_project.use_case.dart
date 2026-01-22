import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';

/// Caso de uso para actualizar un proyecto existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para actualizar un proyecto.
/// Solo se actualizan los campos proporcionados en el DTO.
class UpdateProjectUseCase {
  /// Repositorio de proyectos para acceder a los datos
  final ProjectRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de proyectos inyectado
  UpdateProjectUseCase(this._repository);

  /// Ejecuta el caso de uso para actualizar un proyecto.
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// [dto] - Datos a actualizar (solo los campos que se quieren cambiar)
  /// 
  /// Retorna el proyecto actualizado.
  /// 
  /// Lanza una excepción si hay un error al actualizar el proyecto.
  Future<Project> call(String id, UpdateProjectDto dto) async {
    return await _repository.updateProject(id, dto);
  }
}
