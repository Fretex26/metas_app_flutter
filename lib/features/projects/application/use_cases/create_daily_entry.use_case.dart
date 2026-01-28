import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';
import 'package:metas_app/features/projects/domain/repositories/daily_entry.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_daily_entry.dto.dart';

/// Use case para crear una nueva entrada diaria.
/// 
/// Encapsula la lógica de negocio para crear una entrada diaria,
/// delegando la operación al repositorio correspondiente.
class CreateDailyEntryUseCase {
  /// Repositorio de entradas diarias
  final DailyEntryRepository _repository;

  /// Constructor del use case
  /// 
  /// [repository] - Repositorio de entradas diarias
  CreateDailyEntryUseCase(this._repository);

  /// Ejecuta la creación de una entrada diaria.
  /// 
  /// [dto] - Datos de la entrada diaria a crear
  /// 
  /// Retorna la entrada diaria creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<DailyEntry> call(CreateDailyEntryDto dto) async {
    return await _repository.createDailyEntry(dto);
  }
}
