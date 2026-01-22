/// DTO que representa la respuesta del backend para una task.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear una task.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class TaskResponseDto {
  /// Identificador único de la task (UUID)
  final String id;

  /// Identificador del milestone al que pertenece
  final String milestoneId;

  /// Identificador del sprint asociado (opcional)
  final String? sprintId;

  /// Nombre de la task
  final String name;

  /// Descripción opcional de la task
  final String? description;

  /// Estado de la task: 'pending', 'in_progress' o 'completed'
  final String status;

  /// Fecha de inicio en formato ISO string (YYYY-MM-DD)
  final String startDate;

  /// Fecha de fin en formato ISO string (YYYY-MM-DD)
  final String endDate;

  /// Recursos disponibles como objeto JSON
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios como objeto JSON
  final Map<String, dynamic>? resourcesNeeded;

  /// Puntos de incentivo otorgados al completar la task
  final int? incentivePoints;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de task
  TaskResponseDto({
    required this.id,
    required this.milestoneId,
    this.sprintId,
    required this.name,
    this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.incentivePoints,
    required this.createdAt,
  });

  factory TaskResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskResponseDto(
      id: json['id'] as String,
      milestoneId: json['milestoneId'] as String,
      sprintId: json['sprintId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      resourcesAvailable: json['resourcesAvailable'] as Map<String, dynamic>?,
      resourcesNeeded: json['resourcesNeeded'] as Map<String, dynamic>?,
      incentivePoints: json['incentivePoints'] as int?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'milestoneId': milestoneId,
      if (sprintId != null) 'sprintId': sprintId,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
      if (incentivePoints != null) 'incentivePoints': incentivePoints,
      'createdAt': createdAt,
    };
  }
}
