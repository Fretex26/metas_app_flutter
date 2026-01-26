import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';

/// Use case para actualizar un sprint existente.
/// 
/// Permite actualizar cualquier campo del sprint (todos son opcionales).
/// El backend valida que:
/// - La fecha de fin sea posterior a la fecha de inicio (si se proporcionan fechas)
/// - El período no exceda 4 semanas (28 días) (si se proporcionan fechas)
class UpdateSprintUseCase {
  final SprintRepository _repository;

  UpdateSprintUseCase(this._repository);

  /// Ejecuta la actualización del sprint.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos a actualizar (todos los campos son opcionales)
  /// 
  /// Retorna el sprint actualizado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<Sprint> call(String milestoneId, String sprintId, UpdateSprintDto dto) async {
    return await _repository.updateSprint(milestoneId, sprintId, dto);
  }
}
