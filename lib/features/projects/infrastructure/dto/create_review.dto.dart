/// DTO para crear una nueva review.
/// 
/// Contiene los campos necesarios para crear una review de un sprint.
/// El porcentaje de progreso se calcula automáticamente en el backend.
class CreateReviewDto {
  /// Puntos extra otorgados (opcional, por defecto: 0)
  final int? extraPoints;

  /// Resumen obligatorio de la revisión
  final String summary;

  /// Constructor del DTO para crear review
  CreateReviewDto({
    this.extraPoints,
    required this.summary,
  });

  Map<String, dynamic> toJson() {
    return {
      if (extraPoints != null) 'extraPoints': extraPoints,
      'summary': summary,
    };
  }
}
