import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_tasks.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/presentation/cubits/milestone_detail.states.dart';

class MilestoneDetailCubit extends Cubit<MilestoneDetailState> {
  final GetMilestoneByIdUseCase _getMilestoneByIdUseCase;
  final GetMilestoneTasksUseCase _getMilestoneTasksUseCase;

  MilestoneDetailCubit({
    required GetMilestoneByIdUseCase getMilestoneByIdUseCase,
    required GetMilestoneTasksUseCase getMilestoneTasksUseCase,
  })  : _getMilestoneByIdUseCase = getMilestoneByIdUseCase,
        _getMilestoneTasksUseCase = getMilestoneTasksUseCase,
        super(MilestoneDetailInitial());

  Future<void> loadMilestone(String projectId, String milestoneId) async {
    emit(MilestoneDetailLoading());
    try {
      final results = await Future.wait([
        _getMilestoneByIdUseCase(projectId, milestoneId),
        _getMilestoneTasksUseCase(milestoneId),
      ]);

      emit(MilestoneDetailLoaded(
        milestone: results[0] as Milestone,
        tasks: results[1] as List<Task>,
      ));
    } catch (e) {
      emit(MilestoneDetailError(e.toString()));
    }
  }
}
