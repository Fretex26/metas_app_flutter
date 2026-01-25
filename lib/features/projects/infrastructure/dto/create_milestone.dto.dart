import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';

/// DTO para crear un nuevo milestone dentro de un proyecto.
/// 
/// Contiene los datos necesarios para crear un milestone, incluyendo
/// una recompensa opcional (a diferencia de los proyectos donde es obligatoria).
class CreateMilestoneDto {
  /// Nombre del milestone (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional del milestone
  final String? description;

  /// Recompensa asociada al milestone (opcional)
  final RewardDto? reward;

  /// Constructor del DTO para crear milestone
  CreateMilestoneDto({
    required this.name,
    this.description,
    this.reward,
  });

  /// Convierte el DTO a formato JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (reward != null) 'reward': reward!.toJson(),
    };
  }
}
