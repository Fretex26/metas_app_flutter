import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_milestone.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_milestone.states.dart';

/// Cubit para gestionar el estado de la eliminación de milestones.
class DeleteMilestoneCubit extends Cubit<DeleteMilestoneState> {
  final DeleteMilestoneUseCase _deleteMilestoneUseCase;

  DeleteMilestoneCubit({
    required DeleteMilestoneUseCase deleteMilestoneUseCase,
  })  : _deleteMilestoneUseCase = deleteMilestoneUseCase,
        super(DeleteMilestoneInitial());

  Future<void> deleteMilestone(String projectId, String milestoneId) async {
    emit(DeleteMilestoneLoading());
    try {
      await _deleteMilestoneUseCase(projectId, milestoneId);
      emit(DeleteMilestoneSuccess());
    } catch (e) {
      emit(DeleteMilestoneError(e.toString()));
    }
  }
}
