import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_task_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/components/task_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/milestone_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/milestone_detail.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/create_task.page.dart';
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
        builder: (pageContext) => Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Milestone'),
          ),
          body: BlocBuilder<MilestoneDetailCubit, MilestoneDetailState>(
            builder: (context, state) {
              if (state is MilestoneDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MilestoneDetailError) {
                return Center(
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
                );
              }

              if (state is MilestoneDetailLoaded) {
                final completedTasks = state.tasks.where((t) => t.status == 'completed').length;
                final totalTasks = state.tasks.length;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
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
                                        state.milestone.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    StatusBadge(status: state.milestone.status),
                                  ],
                                ),
                                if (state.milestone.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    state.milestone.description!,
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
                              'Tasks',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${state.tasks.length} tasks',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state.tasks.isEmpty)
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
                          ...state.tasks.map((task) {
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
                                  context.read<MilestoneDetailCubit>().loadMilestone(projectId, milestoneId);
                                });
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
