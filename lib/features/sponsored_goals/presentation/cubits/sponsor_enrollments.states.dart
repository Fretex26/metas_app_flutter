import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';

/// Estados posibles del cubit de inscripciones a Sponsored Goals.
/// 
/// Define todos los estados que puede tener una inscripción:
/// - Estado inicial
/// - Inscribiendo
/// - Inscripción exitosa
/// - Error
abstract class SponsorEnrollmentsState {}

/// Estado inicial antes de realizar una inscripción
class SponsorEnrollmentsInitial extends SponsorEnrollmentsState {}

/// Estado mientras se está procesando la inscripción
class SponsorEnrollmentsEnrolling extends SponsorEnrollmentsState {}

/// Estado cuando la inscripción se ha completado exitosamente.
/// 
/// Contiene la inscripción creada.
class SponsorEnrollmentsEnrolled extends SponsorEnrollmentsState {
  /// Inscripción creada
  final SponsorEnrollment enrollment;

  /// Constructor del estado de inscripción exitosa
  SponsorEnrollmentsEnrolled({required this.enrollment});
}

/// Estado cuando ocurre un error al inscribirse.
/// 
/// Contiene el mensaje de error para mostrarlo al usuario.
class SponsorEnrollmentsError extends SponsorEnrollmentsState {
  /// Mensaje descriptivo del error ocurrido
  final String message;

  /// Constructor del estado de error
  SponsorEnrollmentsError(this.message);
}
