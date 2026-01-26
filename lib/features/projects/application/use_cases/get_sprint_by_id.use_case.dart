import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';

/// Use case para obtener un sprint específico por su ID.
/// 
/// Verifica que el sprint exista y que el usuario tenga permisos para acceder a él.
class GetSprintByIdUseCase {
  final SprintRepository _repository;

  GetSprintByIdUseCase(this._repository);

  /// Ejecuta la obtención del sprint por ID.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna el sprint si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Sprint> call(String milestoneId, String sprintId) async {
    return await _repository.getSprintById(milestoneId, sprintId);
  }
}
