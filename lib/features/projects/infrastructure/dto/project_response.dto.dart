/// DTO que representa la respuesta del backend para un proyecto.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear un proyecto.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class ProjectResponseDto {
  /// Identificador único del proyecto (UUID)
  final String id;

  /// Identificador del usuario propietario
  final String userId;

  /// Nombre del proyecto
  final String name;

  /// Descripción opcional del proyecto
  final String? description;

  /// Propósito u objetivo del proyecto
  final String? purpose;

  /// Presupuesto asignado al proyecto
  final double? budget;

  /// Fecha límite en formato ISO string (YYYY-MM-DD)
  final String? finalDate;

  /// Recursos disponibles como objeto JSON
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios como objeto JSON
  final Map<String, dynamic>? resourcesNeeded;

  /// ID del goal patrocinado (si aplica)
  final String? sponsoredGoalId;

  /// ID de la inscripción asociada
  final String? enrollmentId;

  /// Indica si el proyecto está activo
  final bool isActive;

  /// ID de la recompensa asociada
  final String rewardId;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Estado actual del proyecto: 'pending', 'in_progress' o 'completed'
  final String? status;

  /// Constructor del DTO de respuesta de proyecto
  ProjectResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.purpose,
    this.budget,
    this.finalDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    this.sponsoredGoalId,
    this.enrollmentId,
    required this.isActive,
    required this.rewardId,
    required this.createdAt,
    this.status,
  });

  factory ProjectResponseDto.fromJson(Map<String, dynamic> json) {
    return ProjectResponseDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      purpose: json['purpose'] as String?,
      budget: json['budget'] != null ? (json['budget'] as num).toDouble() : null,
      finalDate: json['finalDate'] as String?,
      resourcesAvailable: json['resourcesAvailable'] as Map<String, dynamic>?,
      resourcesNeeded: json['resourcesNeeded'] as Map<String, dynamic>?,
      sponsoredGoalId: json['sponsoredGoalId'] as String?,
      enrollmentId: json['enrollmentId'] as String?,
      isActive: json['isActive'] as bool,
      rewardId: json['rewardId'] as String,
      createdAt: json['createdAt'] as String,
      status: json['status'] as String?,
    );
  }

  /// Convierte el DTO a formato JSON para enviarlo al backend (si es necesario).
  /// 
  /// Retorna un mapa con todos los campos del proyecto.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      if (description != null) 'description': description,
      if (purpose != null) 'purpose': purpose,
      if (budget != null) 'budget': budget,
      if (finalDate != null) 'finalDate': finalDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
      if (sponsoredGoalId != null) 'sponsoredGoalId': sponsoredGoalId,
      if (enrollmentId != null) 'enrollmentId': enrollmentId,
      'isActive': isActive,
      'rewardId': rewardId,
      'createdAt': createdAt,
      if (status != null) 'status': status,
    };
  }
}
