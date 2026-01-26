import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/sprint.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';

/// Use case para crear un nuevo sprint dentro de un milestone.
/// 
/// Valida que el milestone exista y pertenezca al usuario antes de crear el sprint.
/// El backend valida que:
/// - La fecha de fin sea posterior a la fecha de inicio
/// - El período no exceda 4 semanas (28 días)
class CreateSprintUseCase {
  final SprintRepository _repository;

  CreateSprintUseCase(this._repository);

  /// Ejecuta la creación del sprint.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos del sprint a crear
  /// 
  /// Retorna el sprint creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe o no pertenece al usuario (404)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<Sprint> call(String milestoneId, CreateSprintDto dto) async {
    return await _repository.createSprint(milestoneId, dto);
  }
}
