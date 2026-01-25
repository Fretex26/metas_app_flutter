import 'package:metas_app/features/projects/domain/entities/reward.dart';

/// Estados del cubit de rewards (recompensas).
/// 
/// Define todos los estados posibles para la gestión de rewards.
abstract class RewardsState {}

/// Estado inicial del cubit de rewards
class RewardsInitial extends RewardsState {}

/// Estado de carga de rewards
class RewardsLoading extends RewardsState {}

/// Estado cuando se ha cargado una reward individual
class RewardLoaded extends RewardsState {
  /// Reward cargada
  final Reward reward;

  /// Constructor del estado con reward cargada
  RewardLoaded(this.reward);
}

/// Estado cuando se ha cargado la lista de rewards del usuario
class RewardsListLoaded extends RewardsState {
  /// Lista de rewards del usuario
  final List<Reward> rewards;

  /// Constructor del estado con lista de rewards
  RewardsListLoaded(this.rewards);
}

/// Estado de error al cargar rewards
class RewardsError extends RewardsState {
  /// Mensaje de error
  final String message;

  /// Constructor del estado de error
  RewardsError(this.message);
}
