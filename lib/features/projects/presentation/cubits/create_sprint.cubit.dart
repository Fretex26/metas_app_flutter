import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_sprint.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_sprint.states.dart';

/// Cubit para manejar la creación de sprints.
/// 
/// Gestiona el estado del proceso de creación de un sprint dentro de un milestone.
class CreateSprintCubit extends Cubit<CreateSprintState> {
  final CreateSprintUseCase _createSprintUseCase;

  CreateSprintCubit({required CreateSprintUseCase createSprintUseCase})
      : _createSprintUseCase = createSprintUseCase,
        super(CreateSprintInitial());

  /// Crea un nuevo sprint dentro de un milestone.
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos del sprint a crear
  /// 
  /// Emite estados:
  /// - CreateSprintLoading mientras se procesa
  /// - CreateSprintSuccess con el ID del sprint creado
  /// - CreateSprintError si ocurre un error
  Future<void> createSprint(String milestoneId, CreateSprintDto dto) async {
    emit(CreateSprintLoading());
    try {
      final sprint = await _createSprintUseCase(milestoneId, dto);
      emit(CreateSprintSuccess(sprint.id));
    } catch (e) {
      emit(CreateSprintError(e.toString()));
    }
  }
}
