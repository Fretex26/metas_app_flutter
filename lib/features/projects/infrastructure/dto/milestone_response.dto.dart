/// DTO que representa la respuesta del backend para un milestone.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear un milestone.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class MilestoneResponseDto {
  /// Identificador único del milestone (UUID)
  final String id;

  /// Identificador del proyecto al que pertenece
  final String projectId;

  /// Nombre del milestone
  final String name;

  /// Descripción opcional del milestone
  final String? description;

  /// Estado del milestone: 'pending', 'in_progress' o 'completed'
  final String status;

  /// ID de la recompensa asociada (opcional)
  final String? rewardId;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de milestone
  MilestoneResponseDto({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.status,
    this.rewardId,
    required this.createdAt,
  });

  factory MilestoneResponseDto.fromJson(Map<String, dynamic> json) {
    return MilestoneResponseDto(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      rewardId: json['rewardId'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      if (rewardId != null) 'rewardId': rewardId,
      'createdAt': createdAt,
    };
  }
}
