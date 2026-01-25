import 'package:metas_app/features/projects/application/use_cases/get_project_by_reward_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';

/// Resultado de la búsqueda del estado de la reward.
/// 
/// Contiene información sobre el proyecto o milestone asociado a una reward
/// y su estado de completitud.
class RewardStatusResult {
  /// Proyecto asociado (si la reward es de un proyecto)
  final Project? project;

  /// Milestone asociado (si la reward es de un milestone)
  final Milestone? milestone;

  /// Proyecto padre del milestone (si la reward es de un milestone)
  final Project? parentProject;

  /// Indica si el proyecto/milestone está completado
  final bool isCompleted;

  /// Nombre del proyecto o milestone para mostrar
  final String entityName;

  /// Constructor del resultado
  RewardStatusResult({
    this.project,
    this.milestone,
    this.parentProject,
    required this.isCompleted,
    required this.entityName,
  });
}

/// Helper para obtener el estado del proyecto o milestone asociado a una reward.
/// 
/// Busca la reward en proyectos y milestones del usuario para determinar
/// el estado de completitud y mostrar información relevante.
class RewardProjectStatusHelper {
  /// Caso de uso para obtener proyecto por rewardId
  final GetProjectByRewardIdUseCase _getProjectByRewardIdUseCase;

  /// Caso de uso para obtener proyectos del usuario
  final GetUserProjectsUseCase _getUserProjectsUseCase;

  /// Caso de uso para obtener milestones de un proyecto
  final GetProjectMilestonesUseCase _getProjectMilestonesUseCase;

  /// Constructor del helper
  RewardProjectStatusHelper({
    required GetProjectByRewardIdUseCase getProjectByRewardIdUseCase,
    required GetUserProjectsUseCase getUserProjectsUseCase,
    required GetProjectMilestonesUseCase getProjectMilestonesUseCase,
  })  : _getProjectByRewardIdUseCase = getProjectByRewardIdUseCase,
        _getUserProjectsUseCase = getUserProjectsUseCase,
        _getProjectMilestonesUseCase = getProjectMilestonesUseCase;

  /// Obtiene el estado del proyecto o milestone asociado a una reward.
  /// 
  /// [rewardId] - Identificador único de la reward
  /// 
  /// Retorna información sobre el estado del proyecto o milestone asociado.
  /// Si no se encuentra, retorna un resultado con isCompleted = false.
  Future<RewardStatusResult> getRewardStatus(String rewardId) async {
    try {
      // 1. Intentar buscar en proyectos
      final project = await _getProjectByRewardIdUseCase.call(rewardId);

      if (project != null) {
        return RewardStatusResult(
          project: project,
          isCompleted: project.status == 'completed',
          entityName: project.name,
        );
      }

      // 2. Si no se encuentra en proyectos, buscar en milestones
      final userProjects = await _getUserProjectsUseCase.call();

      for (final userProject in userProjects) {
        try {
          final milestones = await _getProjectMilestonesUseCase.call(userProject.id);
          
          for (final milestone in milestones) {
            if (milestone.rewardId == rewardId) {
              return RewardStatusResult(
                milestone: milestone,
                parentProject: userProject,
                isCompleted: milestone.status == 'completed',
                entityName: milestone.name,
              );
            }
          }
        } catch (e) {
          // Continuar con el siguiente proyecto si hay error
          continue;
        }
      }

      // 3. No se encontró en proyectos ni milestones
      return RewardStatusResult(
        isCompleted: false,
        entityName: 'Proyecto',
      );
    } catch (e) {
      // En caso de error, retornar estado no completado
      return RewardStatusResult(
        isCompleted: false,
        entityName: 'Proyecto',
      );
    }
  }
}
