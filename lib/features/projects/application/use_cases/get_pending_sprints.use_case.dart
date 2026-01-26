import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';
import 'package:metas_app/features/projects/domain/repositories/pending_sprints.repository.dart';

/// Use case para obtener los sprints pendientes de review o retrospectiva.
/// 
/// Este use case encapsula la lógica de negocio para obtener todos los sprints
/// que han finalizado y que aún necesitan review o retrospectiva.
class GetPendingSprintsUseCase {
  final PendingSprintsRepository _repository;

  GetPendingSprintsUseCase(this._repository);

  /// Ejecuta el use case y retorna la lista de sprints pendientes.
  /// 
  /// Retorna una lista de sprints que han finalizado (endDate <= hoy) y que
  /// aún no tienen review o retrospectiva (o ambas).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<List<PendingSprint>> call() async {
    return await _repository.getPendingSprints();
  }
}
