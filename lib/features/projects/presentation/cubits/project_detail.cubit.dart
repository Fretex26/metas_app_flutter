import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_progress.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';
import 'package:metas_app/features/projects/presentation/cubits/project_detail.states.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final GetProjectProgressUseCase _getProjectProgressUseCase;
  final GetProjectMilestonesUseCase _getProjectMilestonesUseCase;

  ProjectDetailCubit({
    required GetProjectByIdUseCase getProjectByIdUseCase,
    required GetProjectProgressUseCase getProjectProgressUseCase,
    required GetProjectMilestonesUseCase getProjectMilestonesUseCase,
  })  : _getProjectByIdUseCase = getProjectByIdUseCase,
        _getProjectProgressUseCase = getProjectProgressUseCase,
        _getProjectMilestonesUseCase = getProjectMilestonesUseCase,
        super(ProjectDetailInitial());

  Future<void> loadProject(String projectId) async {
    emit(ProjectDetailLoading());
    try {
      final results = await Future.wait([
        _getProjectByIdUseCase(projectId),
        _getProjectProgressUseCase(projectId),
        _getProjectMilestonesUseCase(projectId),
      ]);

      emit(ProjectDetailLoaded(
        project: results[0] as Project,
        progress: results[1] as ProjectProgress,
        milestones: results[2] as List<Milestone>,
      ));
    } catch (e) {
      emit(ProjectDetailError(e.toString()));
    }
  }
}
