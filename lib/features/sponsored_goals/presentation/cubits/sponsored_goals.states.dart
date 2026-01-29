import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';

/// Estados posibles del cubit de Sponsored Goals disponibles.
/// 
/// Define todos los estados que puede tener la lista de sponsored goals:
/// - Estado inicial
/// - Cargando
/// - Cargado con éxito
/// - Error
abstract class SponsoredGoalsState {}

/// Estado inicial antes de cargar los sponsored goals
class SponsoredGoalsInitial extends SponsoredGoalsState {}

/// Estado mientras se están cargando los sponsored goals del servidor
class SponsoredGoalsLoading extends SponsoredGoalsState {}

/// Estado cuando los sponsored goals se han cargado exitosamente.
/// 
/// Contiene la lista de sponsored goals disponibles.
class SponsoredGoalsLoaded extends SponsoredGoalsState {
  /// Lista de sponsored goals disponibles
  final List<SponsoredGoal> goals;

  /// IDs de categorías seleccionadas para filtrar (opcional)
  final List<String>? selectedCategoryIds;

  /// Constructor del estado de sponsored goals cargados
  SponsoredGoalsLoaded({
    required this.goals,
    this.selectedCategoryIds,
  });
}

/// Estado cuando ocurre un error al cargar los sponsored goals.
/// 
/// Contiene el mensaje de error para mostrarlo al usuario.
class SponsoredGoalsError extends SponsoredGoalsState {
  /// Mensaje descriptivo del error ocurrido
  final String message;

  /// Constructor del estado de error
  SponsoredGoalsError(this.message);
}
