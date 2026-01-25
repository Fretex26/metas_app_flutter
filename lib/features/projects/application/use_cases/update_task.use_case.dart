import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';

/// Caso de uso para actualizar una task existente.
/// 
/// Este caso de uso encapsula la lógica de negocio para actualizar una task.
/// Solo se actualizan los campos proporcionados en el DTO.
class UpdateTaskUseCase {
  /// Repositorio de tasks para acceder a los datos
  final TaskRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de tasks inyectado
  UpdateTaskUseCase(this._repository);

  /// Ejecuta el caso de uso para actualizar una task.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// [dto] - Datos a actualizar (name, description, fechas, recursos, puntos)
  /// 
  /// Retorna la task actualizada.
  /// 
  /// Lanza una excepción si hay un error al actualizar la task.
  Future<Task> call(String milestoneId, String id, UpdateTaskDto dto) async {
    return await _repository.updateTask(milestoneId, id, dto);
  }
}
