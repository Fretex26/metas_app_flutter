/// DTO que representa el progreso de un proyecto recibido del backend.
/// 
/// Contiene el porcentaje de progreso calculado y las estadísticas de tasks.
class ProjectProgressDto {
  /// Porcentaje de progreso del proyecto (0.0 a 100.0)
  final double progressPercentage;

  /// Número de tasks completadas
  final int completedTasks;

  /// Número total de tasks en el proyecto
  final int totalTasks;

  /// Constructor del DTO de progreso
  ProjectProgressDto({
    required this.progressPercentage,
    required this.completedTasks,
    required this.totalTasks,
  });

  /// Crea una instancia del DTO desde un mapa JSON recibido del backend.
  /// 
  /// [json] - Mapa con los datos de progreso en formato JSON
  /// 
  /// Retorna una instancia de [ProjectProgressDto] con los datos parseados.
  factory ProjectProgressDto.fromJson(Map<String, dynamic> json) {
    return ProjectProgressDto(
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      completedTasks: json['completedTasks'] as int,
      totalTasks: json['totalTasks'] as int,
    );
  }

  /// Convierte el DTO a formato JSON.
  /// 
  /// Retorna un mapa con todos los campos de progreso.
  Map<String, dynamic> toJson() {
    return {
      'progressPercentage': progressPercentage,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
    };
  }
}
