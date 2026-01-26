import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_task_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/projects/presentation/components/task_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_milestone.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_milestone.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_milestone.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/milestone_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/milestone_detail.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.cubit.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_sprints.use_case.dart';
import 'package:metas_app/features/projects/presentation/components/sprint_card.dart';
import 'package:metas_app/features/projects/presentation/pages/create_sprint.page.dart';
import 'package:metas_app/features/projects/presentation/pages/create_task.page.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_milestone.page.dart';
import 'package:metas_app/features/projects/presentation/pages/sprint_detail.page.dart';
import 'package:metas_app/features/projects/presentation/pages/task_detail.page.dart';

/// Página que muestra el detalle completo de un milestone.
/// 
/// Muestra:
/// - Información del milestone (nombre, descripción, estado, progreso)
/// - Lista de tasks con sus tarjetas
/// - Pull-to-refresh para actualizar
/// - FAB para crear nueva task
/// - Navegación al detalle de cada task
class MilestoneDetailPage extends StatelessWidget {
  /// Identificador único del proyecto (para navegación)
  final String projectId;

  /// Identificador único del milestone a mostrar
  final String milestoneId;

  /// Constructor de la página de detalle de milestone
  const MilestoneDetailPage({
    super.key,
    required this.projectId,
    required this.milestoneId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MilestoneDetailCubit(
        getMilestoneByIdUseCase: context.read(),
        getMilestoneTasksUseCase: context.read(),
      )..loadMilestone(projectId, milestoneId),
      child: Builder(
        builder: (pageContext) => BlocBuilder<MilestoneDetailCubit, MilestoneDetailState>(
          builder: (context, state) {
            if (state is MilestoneDetailLoading) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Milestone'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is MilestoneDetailError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Milestone'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MilestoneDetailLoaded) {
              final completedTasks = state.tasks.where((t) => t.status == 'completed').length;
              final totalTasks = state.tasks.length;

              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => EditMilestoneCubit(
                      updateMilestoneUseCase: context.read(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMilestoneCubit(
                      deleteMilestoneUseCase: context.read(),
                    ),
                  ),
                ],
                child: _MilestoneDetailContent(
                  milestone: state.milestone,
                  tasks: state.tasks,
                  completedTasks: completedTasks,
                  totalTasks: totalTasks,
                  projectId: projectId,
                  milestoneId: milestoneId,
                  pageContext: pageContext,
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalle del Milestone'),
              ),
              body: const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Widget interno que muestra el contenido del detalle del milestone
/// con funcionalidad de edición y eliminación.
class _MilestoneDetailContent extends StatelessWidget {
  final dynamic milestone;
  final List<dynamic> tasks;
  final int completedTasks;
  final int totalTasks;
  final String projectId;
  final String milestoneId;
  final BuildContext pageContext;

  const _MilestoneDetailContent({
    required this.milestone,
    required this.tasks,
    required this.completedTasks,
    required this.totalTasks,
    required this.projectId,
    required this.milestoneId,
    required this.pageContext,
  });

  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditMilestoneCubit(
            updateMilestoneUseCase: context.read(),
          ),
          child: EditMilestonePage(
            projectId: projectId,
            milestone: milestone,
          ),
        ),
      ),
    );

    if (result != null && pageContext.mounted) {
      pageContext.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar Milestone',
      message: '¿Estás seguro de que deseas eliminar este milestone? '
          'Esta acción eliminará permanentemente el milestone, todos sus '
          'sprints, tasks, checklist items y datos relacionados. '
          'Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    context.read<DeleteMilestoneCubit>().deleteMilestone(projectId, milestoneId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteMilestoneCubit, DeleteMilestoneState>(
      listener: (context, state) {
        if (state is DeleteMilestoneSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Milestone eliminado exitosamente')),
          );
        } else if (state is DeleteMilestoneError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Milestone'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _handleEdit(context),
            ),
            BlocBuilder<DeleteMilestoneCubit, DeleteMilestoneState>(
              builder: (context, deleteState) {
                final isDeleting = deleteState is DeleteMilestoneLoading;
                return IconButton(
                  icon: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete),
                  onPressed: isDeleting ? null : () => _handleDelete(context),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            pageContext.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
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
                                milestone.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            StatusBadge(status: milestone.status),
                          ],
                        ),
                        if (milestone.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            milestone.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (totalTasks > 0) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Progreso: $completedTasks/$totalTasks tareas completadas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sprints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final result = await Navigator.push(
                          pageContext,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => CreateSprintCubit(
                                createSprintUseCase: context.read(),
                              ),
                              child: CreateSprintPage(milestoneId: milestoneId),
                            ),
                          ),
                        );
                        if (result != null && pageContext.mounted) {
                          pageContext.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
                        }
                      },
                      tooltip: 'Crear Sprint',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder(
                  future: context.read<GetMilestoneSprintsUseCase>()(milestoneId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error al cargar sprints: ${snapshot.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      );
                    }
                    final sprints = snapshot.data ?? [];
                    if (sprints.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.timeline_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay sprints aún',
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
                      children: sprints.map((sprint) {
                        // Contar tasks del sprint
                        final sprintTasks = tasks.where((t) => t.sprintId == sprint.id).toList();
                        return SprintCard(
                          sprint: sprint,
                          taskCount: sprintTasks.length,
                          onTap: () async {
                            final result = await Navigator.push(
                              pageContext,
                              MaterialPageRoute(
                                builder: (context) => SprintDetailPage(
                                  projectId: projectId,
                                  milestoneId: milestoneId,
                                  sprintId: sprint.id,
                                ),
                              ),
                            );
                            if (result != null && pageContext.mounted) {
                              pageContext.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${tasks.length} tasks',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tasks aún',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...tasks.map((task) {
                    final completedItems = 0; // Se calculará en task_detail
                    final totalItems = 0; // Se calculará en task_detail
                    return TaskCard(
                      task: task,
                      completedChecklistItems: completedItems,
                      totalChecklistItems: totalItems,
                      onTap: () {
                        final getTaskByIdUseCase = context.read<GetTaskByIdUseCase>();
                        final getChecklistItemsUseCase = context.read<GetChecklistItemsUseCase>();
                        final createChecklistItemUseCase = context.read<CreateChecklistItemUseCase>();
                        final updateChecklistItemUseCase = context.read<UpdateChecklistItemUseCase>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (_) => TaskDetailCubit(
                                    getTaskByIdUseCase: getTaskByIdUseCase,
                                    getChecklistItemsUseCase: getChecklistItemsUseCase,
                                  )..loadTask(milestoneId, task.id),
                                ),
                                BlocProvider(
                                  create: (_) => ChecklistCubit(
                                    getChecklistItemsUseCase: getChecklistItemsUseCase,
                                    createChecklistItemUseCase: createChecklistItemUseCase,
                                    updateChecklistItemUseCase: updateChecklistItemUseCase,
                                  )..loadChecklistItems(task.id),
                                ),
                              ],
                              child: TaskDetailPage(
                                projectId: projectId,
                                milestoneId: milestoneId,
                                taskId: task.id,
                              ),
                            ),
                          ),
                        ).then((_) {
                          if (pageContext.mounted) {
                            pageContext.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
                          }
                        });
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'milestone_detail_fab',
          onPressed: () {
            final cubit = pageContext.read<MilestoneDetailCubit>();
            Navigator.push(
              pageContext,
              MaterialPageRoute(
                builder: (context) => CreateTaskPage(milestoneId: milestoneId),
              ),
            ).then((_) {
              if (pageContext.mounted) {
                cubit.loadMilestone(projectId, milestoneId);
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
