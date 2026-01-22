import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/update_milestone.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_milestone.states.dart';

/// Cubit para gestionar el estado de la edición de milestones.
class EditMilestoneCubit extends Cubit<EditMilestoneState> {
  final UpdateMilestoneUseCase _updateMilestoneUseCase;

  EditMilestoneCubit({
    required UpdateMilestoneUseCase updateMilestoneUseCase,
  })  : _updateMilestoneUseCase = updateMilestoneUseCase,
        super(EditMilestoneInitial());

  Future<void> updateMilestone(String projectId, String id, UpdateMilestoneDto dto) async {
    emit(EditMilestoneLoading());
    try {
      final updatedMilestone = await _updateMilestoneUseCase(projectId, id, dto);
      emit(EditMilestoneSuccess(updatedMilestone));
    } catch (e) {
      emit(EditMilestoneError(e.toString()));
    }
  }
}
