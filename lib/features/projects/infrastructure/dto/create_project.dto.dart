/// DTO que representa una recompensa (Reward) para proyectos o milestones.
/// 
/// Las recompensas son obligatorias para proyectos y opcionales para milestones.
class RewardDto {
  /// Nombre de la recompensa (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional de la recompensa
  final String? description;

  /// Instrucciones para reclamar la recompensa
  final String? claimInstructions;

  /// URL válida para reclamar la recompensa (máximo 500 caracteres)
  final String? claimLink;

  /// Constructor del DTO de recompensa
  RewardDto({
    required this.name,
    this.description,
    this.claimInstructions,
    this.claimLink,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (claimInstructions != null) 'claimInstructions': claimInstructions,
      if (claimLink != null) 'claimLink': claimLink,
    };
  }
}

/// DTO para crear un nuevo proyecto.
/// 
/// Contiene todos los datos necesarios para crear un proyecto, incluyendo
/// la recompensa obligatoria que debe asociarse al proyecto.
class CreateProjectDto {
  /// Nombre del proyecto (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del proyecto
  final String? description;

  /// Propósito u objetivo del proyecto
  final String? purpose;

  /// Presupuesto asignado al proyecto
  final double? budget;

  /// Fecha límite en formato ISO date: YYYY-MM-DD
  final String? finalDate;

  /// Recursos disponibles (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesAvailable;

  /// Recursos necesarios (objeto JSON)
  /// Formato: { "nombre_recurso": "descripción" }
  final Map<String, dynamic>? resourcesNeeded;

  /// Recompensa asociada al proyecto (obligatoria)
  final RewardDto reward;

  /// Constructor del DTO para crear proyecto
  CreateProjectDto({
    required this.name,
    this.description,
    this.purpose,
    this.budget,
    this.finalDate,
    this.resourcesAvailable,
    this.resourcesNeeded,
    required this.reward,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (purpose != null) 'purpose': purpose,
      if (budget != null) 'budget': budget,
      if (finalDate != null) 'finalDate': finalDate,
      if (resourcesAvailable != null) 'resourcesAvailable': resourcesAvailable,
      if (resourcesNeeded != null) 'resourcesNeeded': resourcesNeeded,
      'reward': reward.toJson(),
    };
  }
}
