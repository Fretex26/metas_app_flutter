import '../entities/daily_entry.dart';
import '../../infrastructure/dto/create_daily_entry.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con entradas diarias.
/// 
/// Define los contratos para crear y obtener entradas diarias.
/// Esta interfaz es implementada por [DailyEntryRepositoryImpl] en la capa de infraestructura.
abstract class DailyEntryRepository {
  /// Crea una nueva entrada diaria.
  /// 
  /// [dto] - Datos de la entrada diaria a crear
  /// 
  /// Retorna la entrada diaria creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<DailyEntry> createDailyEntry(CreateDailyEntryDto dto);

  /// Obtiene todas las entradas diarias del usuario autenticado.
  /// 
  /// Retorna una lista de entradas diarias ordenadas por fecha de creación descendente
  /// (más recientes primero).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<List<DailyEntry>> getUserDailyEntries();

  /// Obtiene la entrada diaria del usuario para una fecha específica.
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
  Future<DailyEntry?> getDailyEntryByDate(DateTime date);
}
