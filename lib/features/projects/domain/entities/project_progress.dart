/// Entidad que representa el progreso de un proyecto.
/// 
/// Contiene información calculada sobre el avance del proyecto basado en las tasks completadas.
/// El progreso se calcula como: (tasks completadas / total de tasks) * 100
class ProjectProgress {
  /// Porcentaje de progreso del proyecto (0.0 a 100.0)
  final double progressPercentage;

  /// Número de tasks completadas en el proyecto
  final int completedTasks;

  /// Número total de tasks en el proyecto
  final int totalTasks;

  /// Constructor de la entidad ProjectProgress
  ProjectProgress({
    required this.progressPercentage,
    required this.completedTasks,
    required this.totalTasks,
  });
}
