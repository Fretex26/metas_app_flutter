import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';
import 'package:metas_app/features/projects/domain/repositories/daily_entry.repository.dart';
import 'package:metas_app/features/projects/infrastructure/datasources/daily_entry_datasource.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_daily_entry.dto.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/daily_entry.mapper.dart';

/// Implementación concreta del repositorio de entradas diarias.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class DailyEntryRepositoryImpl implements DailyEntryRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final DailyEntryDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  DailyEntryRepositoryImpl({DailyEntryDatasource? datasource})
      : _datasource = datasource ?? DailyEntryDatasource();

  @override
  Future<DailyEntry> createDailyEntry(CreateDailyEntryDto dto) async {
    try {
      final responseDto = await _datasource.createDailyEntry(dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DailyEntry>> getUserDailyEntries() async {
    try {
      final dtos = await _datasource.getUserDailyEntries();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DailyEntry?> getDailyEntryByDate(DateTime date, String sprintId) async {
    try {
      final dto = await _datasource.getDailyEntryByDate(date, sprintId);
      return dto?.toDomain();
    } catch (e) {
      rethrow;
    }
  }
}
