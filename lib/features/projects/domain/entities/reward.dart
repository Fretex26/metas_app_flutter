/// Entidad que representa una Reward (Recompensa) en el dominio de la aplicación.
/// 
/// Las recompensas pueden estar asociadas a proyectos (obligatorias) o milestones (opcionales).
/// Una recompensa se alcanza cuando se completa el proyecto o milestone correspondiente.
class Reward {
  /// Identificador único de la recompensa (UUID)
  final String id;

  /// Nombre de la recompensa (requerido, máximo 255 caracteres)
  final String name;

  /// Descripción opcional de la recompensa
  final String? description;

  /// Instrucciones para reclamar la recompensa
  final String? claimInstructions;

  /// URL válida para reclamar la recompensa (máximo 500 caracteres)
  final String? claimLink;

  /// Constructor de la entidad Reward
  Reward({
    required this.id,
    required this.name,
    this.description,
    this.claimInstructions,
    this.claimLink,
  });
}
