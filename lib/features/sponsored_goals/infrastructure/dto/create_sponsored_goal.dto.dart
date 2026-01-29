/// DTO para crear un nuevo Sponsored Goal.
/// 
/// Contiene todos los campos necesarios para crear un objetivo patrocinado.
/// El método de verificación siempre será "manual" según los requisitos.
class CreateSponsoredGoalDto {
  /// Nombre del objetivo patrocinado (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del objetivo
  final String? description;

  /// Identificador del proyecto del sponsor que se usará como base
  final String projectId;

  /// IDs de las categorías asociadas (opcional)
  final List<String>? categoryIds;

  /// Fecha de inicio en formato ISO string (YYYY-MM-DD)
  final String startDate;

  /// Fecha de fin en formato ISO string (YYYY-MM-DD)
  final String endDate;

  /// ID de la recompensa opcional asociada
  final String? rewardId;

  /// Número máximo de usuarios que pueden inscribirse (mínimo 1)
  final int maxUsers;

  /// Constructor del DTO para crear sponsored goal
  CreateSponsoredGoalDto({
    required this.name,
    this.description,
    required this.projectId,
    this.categoryIds,
    required this.startDate,
    required this.endDate,
    this.rewardId,
    required this.maxUsers,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend.
  /// 
  /// Nota: verificationMethod siempre será "manual" según los requisitos.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'projectId': projectId,
      if (categoryIds != null && categoryIds!.isNotEmpty)
        'categoryIds': categoryIds,
      'startDate': startDate,
      'endDate': endDate,
      'verificationMethod': 'manual', // Siempre manual según requisitos
      if (rewardId != null) 'rewardId': rewardId,
      'maxUsers': maxUsers,
    };
  }
}
