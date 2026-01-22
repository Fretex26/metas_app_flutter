import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_milestone.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_milestone.states.dart';

class CreateMilestoneCubit extends Cubit<CreateMilestoneState> {
  final CreateMilestoneUseCase _createMilestoneUseCase;

  CreateMilestoneCubit({required CreateMilestoneUseCase createMilestoneUseCase})
      : _createMilestoneUseCase = createMilestoneUseCase,
        super(CreateMilestoneInitial());

  Future<void> createMilestone(String projectId, CreateMilestoneDto dto) async {
    emit(CreateMilestoneLoading());
    try {
      final milestone = await _createMilestoneUseCase(projectId, dto);
      emit(CreateMilestoneSuccess(milestone.id));
    } catch (e) {
      emit(CreateMilestoneError(e.toString()));
    }
  }
}
