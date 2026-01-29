import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_available_sponsored_goals.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsored_goals.states.dart';

/// Cubit para gestionar el estado de la lista de Sponsored Goals disponibles.
/// 
/// Maneja la carga de sponsored goals disponibles para usuarios normales,
/// incluyendo filtrado por categorías. Emite estados de carga, éxito y error
/// para que la UI pueda reaccionar.
class SponsoredGoalsCubit extends Cubit<SponsoredGoalsState> {
  /// Caso de uso para obtener los sponsored goals disponibles
  final GetAvailableSponsoredGoalsUseCase _getAvailableSponsoredGoalsUseCase;

  /// Constructor del cubit
  /// 
  /// [getAvailableSponsoredGoalsUseCase] - Caso de uso para obtener sponsored goals
  SponsoredGoalsCubit({
    required GetAvailableSponsoredGoalsUseCase getAvailableSponsoredGoalsUseCase,
  })  : _getAvailableSponsoredGoalsUseCase = getAvailableSponsoredGoalsUseCase,
        super(SponsoredGoalsInitial());

  /// Carga los sponsored goals disponibles.
  /// 
  /// [categoryIds] - IDs de categorías opcionales para filtrar
  /// 
  /// Emite:
  /// - [SponsoredGoalsLoading] mientras carga
  /// - [SponsoredGoalsLoaded] con los sponsored goals
  /// - [SponsoredGoalsError] si hay un error
  Future<void> loadSponsoredGoals({List<String>? categoryIds}) async {
    emit(SponsoredGoalsLoading());
    try {
      final goals = await _getAvailableSponsoredGoalsUseCase(
        categoryIds: categoryIds,
      );
      emit(SponsoredGoalsLoaded(
        goals: goals,
        selectedCategoryIds: categoryIds,
      ));
    } catch (e) {
      emit(SponsoredGoalsError(e.toString()));
    }
  }
}
