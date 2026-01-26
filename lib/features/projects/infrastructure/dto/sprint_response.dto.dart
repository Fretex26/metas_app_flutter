/// DTO que representa la respuesta del backend para un sprint.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear un sprint.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class SprintResponseDto {
  /// Identificador único del sprint (UUID)
  final String id;

  /// Identificador del milestone al que pertenece
  final String milestoneId;

  /// Nombre del sprint
  final String name;

  /// Descripción opcional del sprint
  final String? description;

  /// Criterios de aceptación del sprint (objeto JSON opcional)
  final Map<String, dynamic>? acceptanceCriteria;

  /// Fecha de inicio en formato ISO string
  final String startDate;

  /// Fecha de fin en formato ISO string
  final String endDate;

  /// Recursos disponibles (objeto JSON opcional)
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios (objeto JSON opcional)
  final Map<String, dynamic>? resourcesNeeded;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de sprint
  SprintResponseDto({
    required this.id,
    required this.milestoneId,
    required this.name,
    this.description,
    this.acceptanceCriteria,
    required this.startDate,
    required this.endDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    required this.createdAt,
  });

  factory SprintResponseDto.fromJson(Map<String, dynamic> json) {
    return SprintResponseDto(
      id: json['id'] as String,
      milestoneId: json['milestoneId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      acceptanceCriteria: json['acceptanceCriteria'] as Map<String, dynamic>?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      resourcesAvailable: json['resourcesAvailable'] as Map<String, dynamic>?,
      resourcesNeeded: json['resourcesNeeded'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'milestoneId': milestoneId,
      'name': name,
      if (description != null) 'description': description,
      if (acceptanceCriteria != null) 'acceptanceCriteria': acceptanceCriteria,
      'startDate': startDate,
      'endDate': endDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
      'createdAt': createdAt,
    };
  }
}
