import 'package:metas_app/features/projects/domain/entities/project_progress.dart';
import 'package:metas_app/features/projects/infrastructure/dto/project_progress.dto.dart';

/// Extensión para mapear [ProjectProgressDto] a la entidad de dominio [ProjectProgress].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio.
/// En este caso, la estructura es idéntica, pero el mapeo mantiene la separación
/// entre capas de Clean Architecture.
extension ProjectProgressDtoMapper on ProjectProgressDto {
  /// Convierte el DTO de respuesta a una entidad ProjectProgress del dominio.
  /// 
  /// Retorna una instancia de [ProjectProgress] con todos los datos mapeados.
  ProjectProgress toDomain() {
    return ProjectProgress(
      progressPercentage: progressPercentage,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
    );
  }
}
