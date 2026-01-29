import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/create_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/create_sponsored_goal.states.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';

/// Cubit para gestionar el estado de la creación de Sponsored Goals.
/// 
/// Maneja la creación de sponsored goals por parte de sponsors.
/// Emite estados de creación, éxito y error para que la UI pueda reaccionar.
class CreateSponsoredGoalCubit extends Cubit<CreateSponsoredGoalState> {
  /// Caso de uso para crear un sponsored goal
  final CreateSponsoredGoalUseCase _createSponsoredGoalUseCase;

  /// Constructor del cubit
  /// 
  /// [createSponsoredGoalUseCase] - Caso de uso para crear sponsored goal
  CreateSponsoredGoalCubit({
    required CreateSponsoredGoalUseCase createSponsoredGoalUseCase,
  })  : _createSponsoredGoalUseCase = createSponsoredGoalUseCase,
        super(CreateSponsoredGoalInitial());

  /// Crea un nuevo sponsored goal.
  /// 
  /// [dto] - Datos del sponsored goal a crear
  /// 
  /// Emite:
  /// - [CreateSponsoredGoalCreating] mientras se crea
  /// - [CreateSponsoredGoalCreated] con el sponsored goal creado
  /// - [CreateSponsoredGoalError] si hay un error
  /// 
  /// Nota: Solo puede ser llamado por sponsors aprobados.
  Future<void> createSponsoredGoal(CreateSponsoredGoalDto dto) async {
    emit(CreateSponsoredGoalCreating());
    try {
      final goal = await _createSponsoredGoalUseCase(dto);
      emit(CreateSponsoredGoalCreated(goal: goal));
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(CreateSponsoredGoalError(msg));
    }
  }

  /// Reinicia el estado a inicial.
  /// 
  /// Útil para limpiar el estado después de mostrar mensajes de éxito/error.
  void reset() {
    emit(CreateSponsoredGoalInitial());
  }
}
