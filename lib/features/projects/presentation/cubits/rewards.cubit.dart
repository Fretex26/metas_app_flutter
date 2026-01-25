import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_reward_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_rewards.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.states.dart';

/// Cubit para gestionar el estado de las rewards (recompensas).
/// 
/// Maneja la carga de rewards individuales y la lista de todas las rewards del usuario.
class RewardsCubit extends Cubit<RewardsState> {
  /// Caso de uso para obtener una reward por ID
  final GetRewardByIdUseCase _getRewardByIdUseCase;

  /// Caso de uso para obtener todas las rewards del usuario
  final GetUserRewardsUseCase _getUserRewardsUseCase;

  /// Constructor del cubit
  /// 
  /// [getRewardByIdUseCase] - Caso de uso para obtener reward por ID
  /// [getUserRewardsUseCase] - Caso de uso para obtener todas las rewards
  RewardsCubit({
    required GetRewardByIdUseCase getRewardByIdUseCase,
    required GetUserRewardsUseCase getUserRewardsUseCase,
  })  : _getRewardByIdUseCase = getRewardByIdUseCase,
        _getUserRewardsUseCase = getUserRewardsUseCase,
        super(RewardsInitial());

  /// Carga una reward específica por su ID.
  /// 
  /// [rewardId] - Identificador único de la reward
  /// 
  /// Emite:
  /// - [RewardsLoading] mientras carga
  /// - [RewardLoaded] con la reward obtenida
  /// - [RewardsError] si hay un error
  Future<void> loadReward(String rewardId) async {
    emit(RewardsLoading());
    try {
      final reward = await _getRewardByIdUseCase(rewardId);
      emit(RewardLoaded(reward));
    } catch (e) {
      emit(RewardsError(e.toString()));
    }
  }

  /// Carga todas las rewards del usuario autenticado.
  /// 
  /// Emite:
  /// - [RewardsLoading] mientras carga
  /// - [RewardsListLoaded] con la lista de rewards
  /// - [RewardsError] si hay un error
  Future<void> loadUserRewards() async {
    emit(RewardsLoading());
    try {
      final rewards = await _getUserRewardsUseCase();
      emit(RewardsListLoaded(rewards));
    } catch (e) {
      emit(RewardsError(e.toString()));
    }
  }
}
