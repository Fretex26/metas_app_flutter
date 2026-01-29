import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';

/// Estados posibles del cubit para crear Sponsored Goals.
/// 
/// Define todos los estados que puede tener la creación de un sponsored goal:
/// - Estado inicial
/// - Creando
/// - Creado con éxito
/// - Error
abstract class CreateSponsoredGoalState {}

/// Estado inicial antes de crear un sponsored goal
class CreateSponsoredGoalInitial extends CreateSponsoredGoalState {}

/// Estado mientras se está creando el sponsored goal
class CreateSponsoredGoalCreating extends CreateSponsoredGoalState {}

/// Estado cuando el sponsored goal se ha creado exitosamente.
/// 
/// Contiene el sponsored goal creado.
class CreateSponsoredGoalCreated extends CreateSponsoredGoalState {
  /// Sponsored goal creado
  final SponsoredGoal goal;

  /// Constructor del estado de creación exitosa
  CreateSponsoredGoalCreated({required this.goal});
}

/// Estado cuando ocurre un error al crear el sponsored goal.
/// 
/// Contiene el mensaje de error para mostrarlo al usuario.
class CreateSponsoredGoalError extends CreateSponsoredGoalState {
  /// Mensaje descriptivo del error ocurrido
  final String message;

  /// Constructor del estado de error
  CreateSponsoredGoalError(this.message);
}
