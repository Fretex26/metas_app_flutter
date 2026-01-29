import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/enroll_in_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_enrollments.states.dart';

/// Cubit para gestionar el estado de las inscripciones a Sponsored Goals.
/// 
/// Maneja la inscripción de usuarios normales a sponsored goals.
/// Emite estados de inscripción, éxito y error para que la UI pueda reaccionar.
class SponsorEnrollmentsCubit extends Cubit<SponsorEnrollmentsState> {
  /// Caso de uso para inscribirse a un sponsored goal
  final EnrollInSponsoredGoalUseCase _enrollInSponsoredGoalUseCase;

  /// Constructor del cubit
  /// 
  /// [enrollInSponsoredGoalUseCase] - Caso de uso para inscribirse
  SponsorEnrollmentsCubit({
    required EnrollInSponsoredGoalUseCase enrollInSponsoredGoalUseCase,
  })  : _enrollInSponsoredGoalUseCase = enrollInSponsoredGoalUseCase,
        super(SponsorEnrollmentsInitial());

  /// Inscribe al usuario actual a un sponsored goal.
  /// 
  /// [sponsoredGoalId] - Identificador único del sponsored goal
  /// 
  /// Emite:
  /// - [SponsorEnrollmentsEnrolling] mientras se procesa
  /// - [SponsorEnrollmentsEnrolled] con la inscripción creada
  /// - [SponsorEnrollmentsError] si hay un error
  /// 
  /// Nota: El proyecto se duplica automáticamente en los proyectos del usuario.
  Future<void> enrollInSponsoredGoal(String sponsoredGoalId) async {
    emit(SponsorEnrollmentsEnrolling());
    try {
      final enrollment = await _enrollInSponsoredGoalUseCase(sponsoredGoalId);
      emit(SponsorEnrollmentsEnrolled(enrollment: enrollment));
    } catch (e) {
      emit(SponsorEnrollmentsError(e.toString()));
    }
  }

  /// Reinicia el estado a inicial.
  /// 
  /// Útil para limpiar el estado después de mostrar mensajes de éxito/error.
  void reset() {
    emit(SponsorEnrollmentsInitial());
  }
}
