import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';
import 'package:metas_app/features/projects/domain/repositories/daily_entry.repository.dart';

/// Use case para obtener todas las entradas diarias del usuario autenticado.
/// 
/// Encapsula la lógica de negocio para obtener las entradas diarias del usuario,
/// delegando la operación al repositorio correspondiente.
class GetUserDailyEntriesUseCase {
  /// Repositorio de entradas diarias
  final DailyEntryRepository _repository;

  /// Constructor del use case
  /// 
  /// [repository] - Repositorio de entradas diarias
  GetUserDailyEntriesUseCase(this._repository);

  /// Ejecuta la obtención de todas las entradas diarias del usuario.
  /// 
  /// Retorna una lista de entradas diarias ordenadas por fecha de creación descendente
  /// (más recientes primero).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<List<DailyEntry>> call() async {
    return await _repository.getUserDailyEntries();
  }
}
