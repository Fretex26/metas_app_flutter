/// DTO para crear una nueva retrospectiva.
/// 
/// Contiene los campos necesarios para crear una retrospectiva de un sprint.
class CreateRetrospectiveDto {
  /// Lo que salió bien durante el sprint (requerido)
  final String whatWentWell;

  /// Lo que salió mal durante el sprint (requerido)
  final String whatWentWrong;

  /// Mejoras propuestas para futuros sprints (opcional)
  final String? improvements;

  /// Indica si la retrospectiva es pública (opcional, por defecto: false)
  final bool? isPublic;

  /// Constructor del DTO para crear retrospectiva
  CreateRetrospectiveDto({
    required this.whatWentWell,
    required this.whatWentWrong,
    this.improvements,
    this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'whatWentWell': whatWentWell,
      'whatWentWrong': whatWentWrong,
      if (improvements != null) 'improvements': improvements,
      if (isPublic != null) 'isPublic': isPublic,
    };
  }
}
