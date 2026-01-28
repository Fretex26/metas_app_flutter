import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';

/// Interfaz del repositorio para operaciones relacionadas con sprints pendientes.
/// 
/// Define los contratos para obtener sprints que necesitan review o retrospectiva.
/// Esta interfaz es implementada por [PendingSprintsRepositoryImpl] en la capa de infraestructura.
abstract class PendingSprintsRepository {
  /// Obtiene todos los sprints pendientes de review o retrospectiva.
  /// 
  /// Retorna una lista de sprints que han finalizado (endDate <= hoy) y que
  /// aún no tienen review o retrospectiva (o ambas).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<List<PendingSprint>> getPendingSprints();
}
