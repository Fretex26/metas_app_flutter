import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';
import 'package:metas_app/features/projects/domain/repositories/daily_entry.repository.dart';

/// Use case para obtener la entrada diaria del usuario para una fecha específica.
/// 
/// Encapsula la lógica de negocio para obtener una entrada diaria por fecha,
/// delegando la operación al repositorio correspondiente.
class GetDailyEntryByDateUseCase {
  /// Repositorio de entradas diarias
  final DailyEntryRepository _repository;

  /// Constructor del use case
  /// 
  /// [repository] - Repositorio de entradas diarias
  GetDailyEntryByDateUseCase(this._repository);

  /// Ejecuta la obtención de la entrada diaria para una fecha específica.
  /// 
  /// [date] - Fecha para buscar la entrada diaria
  /// 
  /// Retorna la entrada diaria si existe para esa fecha, o null si no existe.
  /// La búsqueda se realiza comparando el campo createdAt con el rango del día completo.
  /// 
  /// Lanza una excepción si:
  /// - Formato de fecha inválido (400)
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<DailyEntry?> call(DateTime date) async {
    return await _repository.getDailyEntryByDate(date);
  }
}
