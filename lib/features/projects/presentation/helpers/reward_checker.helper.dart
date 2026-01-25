import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_tasks.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_reward_by_id.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/reward.dart';

/// Helper para verificar si se alcanzó una reward al completar checklist items.
/// 
/// Verifica si al completar todos los checklist items de una task, se completó
/// el milestone o proyecto correspondiente, y si tienen rewards asociadas.
class RewardCheckerHelper {
  /// Caso de uso para obtener checklist items de una task
  final GetChecklistItemsUseCase _getChecklistItemsUseCase;

  /// Caso de uso para obtener milestone por ID
  final GetMilestoneByIdUseCase _getMilestoneByIdUseCase;

  /// Caso de uso para obtener tasks de un milestone
  final GetMilestoneTasksUseCase _getMilestoneTasksUseCase;

  /// Caso de uso para obtener proyecto por ID
  final GetProjectByIdUseCase _getProjectByIdUseCase;

  /// Caso de uso para obtener milestones de un proyecto
  final GetProjectMilestonesUseCase _getProjectMilestonesUseCase;

  /// Caso de uso para obtener reward por ID
  final GetRewardByIdUseCase _getRewardByIdUseCase;

  /// Constructor del helper
  RewardCheckerHelper({
    required GetChecklistItemsUseCase getChecklistItemsUseCase,
    required GetMilestoneByIdUseCase getMilestoneByIdUseCase,
    required GetMilestoneTasksUseCase getMilestoneTasksUseCase,
    required GetProjectByIdUseCase getProjectByIdUseCase,
    required GetProjectMilestonesUseCase getProjectMilestonesUseCase,
    required GetRewardByIdUseCase getRewardByIdUseCase,
  })  : _getChecklistItemsUseCase = getChecklistItemsUseCase,
        _getMilestoneByIdUseCase = getMilestoneByIdUseCase,
        _getMilestoneTasksUseCase = getMilestoneTasksUseCase,
        _getProjectByIdUseCase = getProjectByIdUseCase,
        _getProjectMilestonesUseCase = getProjectMilestonesUseCase,
        _getRewardByIdUseCase = getRewardByIdUseCase;

  /// Verifica si una task está completada basándose en sus checklist items.
  /// 
  /// Una task se considera completada cuando todos sus checklist items requeridos
  /// están marcados como completados (isChecked == true).
  /// 
  /// [taskId] - ID de la task a verificar
  /// 
  /// Retorna true si la task está completada, false en caso contrario.
  Future<bool> _isTaskCompleted(String taskId) async {
    try {
      final checklistItems = await _getChecklistItemsUseCase(taskId);
      
      // Si no hay checklist items, la task no está completada
      if (checklistItems.isEmpty) {
        return false;
      }
      
      // Verificar si todos los checklist items requeridos están completados
      final requiredItems = checklistItems.where((item) => item.isRequired).toList();
      
      // Si no hay items requeridos, verificar si todos los items están completados
      if (requiredItems.isEmpty) {
        return checklistItems.every((item) => item.isChecked);
      }
      
      // Verificar si todos los items requeridos están completados
      return requiredItems.every((item) => item.isChecked);
    } catch (e) {
      // Si hay un error al obtener los checklist items, retornar false
      return false;
    }
  }

  /// Verifica si se alcanzó alguna reward después de completar una task.
  /// 
  /// [projectId] - ID del proyecto
  /// [milestoneId] - ID del milestone
  /// [taskId] - ID de la task que se completó
  /// 
  /// Retorna una lista de rewards alcanzadas (puede ser del milestone y/o proyecto).
  /// Retorna lista vacía si no se alcanzó ninguna reward.
  Future<List<Reward>> checkRewardsAchieved(
    String projectId,
    String milestoneId,
    String taskId,
  ) async {
    final List<Reward> achievedRewards = [];

    try {
      // 1. Verificar si todas las tasks del milestone están completadas
      final milestoneTasks = await _getMilestoneTasksUseCase(milestoneId);
      
      // Verificar cada task usando sus checklist items
      bool allTasksCompleted = true;
      for (final task in milestoneTasks) {
        final isCompleted = await _isTaskCompleted(task.id);
        if (!isCompleted) {
          allTasksCompleted = false;
          break;
        }
      }

      if (allTasksCompleted) {
        // 2. Obtener el milestone para verificar si tiene reward
        final milestone = await _getMilestoneByIdUseCase(projectId, milestoneId);

        if (milestone.rewardId != null) {
          // 3. Obtener la reward del milestone
          final milestoneReward = await _getRewardByIdUseCase(milestone.rewardId!);
          achievedRewards.add(milestoneReward);
        }

        // 4. Verificar si todas las tasks de todos los milestones del proyecto están completadas
        final projectMilestones = await _getProjectMilestonesUseCase(projectId);
        bool allMilestonesCompleted = true;

        for (final milestone in projectMilestones) {
          final tasks = await _getMilestoneTasksUseCase(milestone.id);
          
          // Verificar cada task usando sus checklist items
          for (final task in tasks) {
            final isCompleted = await _isTaskCompleted(task.id);
            if (!isCompleted) {
              allMilestonesCompleted = false;
              break;
            }
          }
          
          if (!allMilestonesCompleted) {
            break;
          }
        }

        if (allMilestonesCompleted) {
          // 5. Obtener el proyecto para verificar si tiene reward
          final project = await _getProjectByIdUseCase(projectId);

          // 6. Obtener la reward del proyecto (siempre tiene reward)
          final projectReward = await _getRewardByIdUseCase(project.rewardId);
          achievedRewards.add(projectReward);
        }
      }
    } catch (e) {
      // Si hay un error, retornar lista vacía (no mostrar dialog de error)
      // El error se manejará silenciosamente
      return [];
    }

    return achievedRewards;
  }
}
