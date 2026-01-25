import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_tasks.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_reward_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/presentation/components/checklist_item_widget.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/projects/presentation/components/reward_achieved_dialog.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_checklist_item.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_checklist_item.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_task.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.states.dart';
import 'package:metas_app/features/projects/presentation/helpers/reward_checker.helper.dart';
import 'package:metas_app/features/projects/presentation/pages/create_checklist_item.page.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_checklist_item.page.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_task.page.dart';
import 'package:metas_app/features/projects/presentation/pages/rewards_list.page.dart';

/// Página que muestra el detalle completo de una task.
/// 
/// Muestra:
/// - Información de la task (nombre, descripción, estado, fechas, puntos de incentivo)
/// - Lista de checklist items con checkboxes interactivos
/// - Pull-to-refresh para actualizar (recarga task y checklist items)
/// - FAB para crear nuevo checklist item
/// - Botones de editar y eliminar en el AppBar
/// - Opciones para editar y eliminar cada checklist item
/// 
/// Al marcar/desmarcar checklist items, el estado de la task se actualiza automáticamente
/// en el backend según las reglas de dependencias.
class TaskDetailPage extends StatefulWidget {
  /// Identificador único del proyecto (para navegación)
  final String projectId;

  /// Identificador único del milestone (para navegación)
  final String milestoneId;

  /// Identificador único de la task a mostrar
  final String taskId;

  /// Constructor de la página de detalle de task
  const TaskDetailPage({
    super.key,
    required this.projectId,
    required this.milestoneId,
    required this.taskId,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (context, taskState) {
        if (taskState is TaskDetailLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de la Task'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (taskState is TaskDetailError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de la Task'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    taskState.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskDetailCubit>().loadTask(widget.milestoneId, widget.taskId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (taskState is TaskDetailLoaded) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => EditTaskCubit(
                  updateTaskUseCase: context.read(),
                ),
              ),
              BlocProvider(
                create: (context) => DeleteTaskCubit(
                  deleteTaskUseCase: context.read(),
                ),
              ),
              BlocProvider(
                create: (context) => DeleteChecklistItemCubit(
                  deleteChecklistItemUseCase: context.read(),
                ),
              ),
            ],
            child: _TaskDetailContent(
              task: taskState.task,
              projectId: widget.projectId,
              milestoneId: widget.milestoneId,
              taskId: widget.taskId,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de la Task'),
          ),
          body: const SizedBox.shrink(),
        );
      },
    );
  }

}

/// Widget interno que muestra el contenido del detalle de la task
/// con funcionalidad de edición y eliminación.
class _TaskDetailContent extends StatelessWidget {
  final dynamic task;
  final String projectId;
  final String milestoneId;
  final String taskId;

  const _TaskDetailContent({
    required this.task,
    required this.projectId,
    required this.milestoneId,
    required this.taskId,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleEditTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditTaskCubit(
            updateTaskUseCase: context.read(),
          ),
          child: EditTaskPage(
            milestoneId: milestoneId,
            task: task,
          ),
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
    }
  }

  Future<void> _handleDeleteTask(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar Task',
      message: '¿Estás seguro de que deseas eliminar esta task? '
          'Esta acción eliminará permanentemente la task y todos sus '
          'checklist items. Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    context.read<DeleteTaskCubit>().deleteTask(milestoneId, taskId);
  }

  Future<void> _handleEditChecklistItem(BuildContext context, dynamic item) async {
    // Intentar obtener el ChecklistCubit del contexto padre
    ChecklistCubit checklistCubit;
    try {
      checklistCubit = context.read<ChecklistCubit>();
    } catch (e) {
      // Si no existe, crear uno nuevo
      final getChecklistItemsUseCase = context.read<GetChecklistItemsUseCase>();
      final createChecklistItemUseCase = context.read<CreateChecklistItemUseCase>();
      final updateChecklistItemUseCase = context.read<UpdateChecklistItemUseCase>();
      checklistCubit = ChecklistCubit(
        getChecklistItemsUseCase: getChecklistItemsUseCase,
        createChecklistItemUseCase: createChecklistItemUseCase,
        updateChecklistItemUseCase: updateChecklistItemUseCase,
      )..loadChecklistItems(taskId);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: checklistCubit,
          child: EditChecklistItemPage(
            taskId: taskId,
            item: item,
          ),
        ),
      ),
    );

    if (result != null && context.mounted) {
      checklistCubit.loadChecklistItems(taskId);
      context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
    }
  }

  Future<void> _handleDeleteChecklistItem(BuildContext context, dynamic item) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar Checklist Item',
      message: '¿Eliminar este elemento de la lista?',
      confirmText: 'Eliminar',
    );

    if (!confirmed) return;

    context.read<DeleteChecklistItemCubit>().deleteChecklistItem(taskId, item.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteTaskCubit, DeleteTaskState>(
      listener: (context, state) {
        if (state is DeleteTaskSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task eliminada exitosamente')),
          );
        } else if (state is DeleteTaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocListener<DeleteChecklistItemCubit, DeleteChecklistItemState>(
        listener: (context, state) {
          if (state is DeleteChecklistItemSuccess) {
            try {
              context.read<ChecklistCubit>().loadChecklistItems(taskId);
            } catch (e) {
              // ChecklistCubit no disponible, se recargará cuando se navegue de vuelta
            }
            context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checklist item eliminado exitosamente')),
            );
          } else if (state is DeleteChecklistItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de la Task'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _handleEditTask(context),
              ),
              BlocBuilder<DeleteTaskCubit, DeleteTaskState>(
                builder: (context, deleteState) {
                  final isDeleting = deleteState is DeleteTaskLoading;
                  return IconButton(
                    icon: isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    onPressed: isDeleting ? null : () => _handleDeleteTask(context),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
              try {
                context.read<ChecklistCubit>().loadChecklistItems(taskId);
              } catch (e) {
                // ChecklistCubit no disponible, se recargará cuando se navegue de vuelta
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              StatusBadge(status: task.status),
                            ],
                          ),
                          if (task.description != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              task.description!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatDate(task.startDate)} - ${_formatDate(task.endDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                ),
                              ),
                              if (task.incentivePoints != null) ...[
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.incentivePoints} pts',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Checklist Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ChecklistCubit, ChecklistState>(
                    builder: (context, checklistState) {
                      if (checklistState is ChecklistLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (checklistState is ChecklistError) {
                        return Center(
                          child: Text(
                            checklistState.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }

                      if (checklistState is ChecklistLoaded ||
                          checklistState is ChecklistItemUpdating) {
                        final items = checklistState is ChecklistLoaded
                            ? checklistState.items
                            : (checklistState as ChecklistItemUpdating).items;
                        final updatingId = checklistState is ChecklistItemUpdating
                            ? checklistState.updatingItemId
                            : null;

                        if (items.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.checklist_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay checklist items aún',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: items.map((item) {
                            return ChecklistItemWidget(
                              item: item,
                              isLoading: updatingId == item.id,
                              onToggle: () async {
                                try {
                                  final wasUnchecked = item.isChecked;
                                  await context.read<ChecklistCubit>().toggleChecklistItem(taskId, item);
                                  if (context.mounted) {
                                    context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
                                    
                                    // Solo verificar rewards si se marcó como completado (no si se desmarcó)
                                    if (!wasUnchecked) {
                                      // Guardar referencias necesarias antes de operaciones asíncronas
                                      final navigator = Navigator.of(context);
                                      final getChecklistItemsUseCase = context.read<GetChecklistItemsUseCase>();
                                      final getMilestoneByIdUseCase = context.read<GetMilestoneByIdUseCase>();
                                      final getMilestoneTasksUseCase = context.read<GetMilestoneTasksUseCase>();
                                      final getProjectByIdUseCase = context.read<GetProjectByIdUseCase>();
                                      final getProjectMilestonesUseCase = context.read<GetProjectMilestonesUseCase>();
                                      final getRewardByIdUseCase = context.read<GetRewardByIdUseCase>();
                                      
                                      // Ejecutar la verificación de forma completamente asíncrona
                                      // Usar Future.microtask para ejecutar después del ciclo de eventos actual
                                      Future.microtask(() async {
                                        // Delay para asegurar que el backend y el widget estén estables
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        
                                        // Verificar si el navigator sigue montado (más estable que context.mounted)
                                        if (!navigator.mounted) return;
                                        
                                        final rewardChecker = RewardCheckerHelper(
                                          getChecklistItemsUseCase: getChecklistItemsUseCase,
                                          getMilestoneByIdUseCase: getMilestoneByIdUseCase,
                                          getMilestoneTasksUseCase: getMilestoneTasksUseCase,
                                          getProjectByIdUseCase: getProjectByIdUseCase,
                                          getProjectMilestonesUseCase: getProjectMilestonesUseCase,
                                          getRewardByIdUseCase: getRewardByIdUseCase,
                                        );
                                        
                                        final achievedRewards = await rewardChecker.checkRewardsAchieved(
                                          projectId,
                                          milestoneId,
                                          taskId,
                                        );
                                        
                                        // Verificar el navigator antes de mostrar el diálogo
                                        if (navigator.mounted && achievedRewards.isNotEmpty) {
                                          // Usar el contexto del navigator para mostrar el diálogo
                                          final dialogContext = navigator.context;
                                          if (dialogContext.mounted) {
                                            await RewardAchievedDialog.show(
                                              context: dialogContext,
                                              rewards: achievedRewards,
                                              onViewDetails: () {
                                                navigator.push(
                                                  MaterialPageRoute(
                                                    builder: (context) => RewardsListPage(),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        }
                                      });
                                    }
                                  }
                                } catch (e) {
                                  // ChecklistCubit no disponible o error al verificar rewards
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error al actualizar checklist item')),
                                    );
                                  }
                                }
                              },
                              onEdit: () => _handleEditChecklistItem(context, item),
                              onDelete: () => _handleDeleteChecklistItem(context, item),
                            );
                          }).toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'task_detail_fab',
            onPressed: () {
              ChecklistCubit checklistCubit;
              try {
                checklistCubit = context.read<ChecklistCubit>();
              } catch (e) {
                // Si no existe, crear uno nuevo
                final getChecklistItemsUseCase = context.read<GetChecklistItemsUseCase>();
                final createChecklistItemUseCase = context.read<CreateChecklistItemUseCase>();
                final updateChecklistItemUseCase = context.read<UpdateChecklistItemUseCase>();
                checklistCubit = ChecklistCubit(
                  getChecklistItemsUseCase: getChecklistItemsUseCase,
                  createChecklistItemUseCase: createChecklistItemUseCase,
                  updateChecklistItemUseCase: updateChecklistItemUseCase,
                )..loadChecklistItems(taskId);
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: checklistCubit,
                    child: CreateChecklistItemPage(taskId: taskId),
                  ),
                ),
              ).then((_) {
                if (context.mounted) {
                  checklistCubit.loadChecklistItems(taskId);
                }
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
