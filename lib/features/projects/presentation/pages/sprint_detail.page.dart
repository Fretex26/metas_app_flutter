import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/projects/presentation/components/task_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/create_task.page.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_sprint.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/sprint_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/sprint_detail.states.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_sprint.page.dart';

/// Página que muestra el detalle completo de un sprint.
/// 
/// Muestra:
/// - Información del sprint (nombre, descripción, fechas, duración)
/// - Lista de tasks asociadas al sprint
/// - Pull-to-refresh para actualizar
/// - Opciones para editar y eliminar el sprint
class SprintDetailPage extends StatelessWidget {
  /// Identificador único del milestone (para navegación)
  final String milestoneId;

  /// Identificador único del sprint a mostrar
  final String sprintId;

  /// Constructor de la página de detalle de sprint
  const SprintDetailPage({
    super.key,
    required this.milestoneId,
    required this.sprintId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SprintDetailCubit(
        getSprintByIdUseCase: context.read(),
        getSprintTasksUseCase: context.read(),
      )..loadSprint(milestoneId, sprintId),
      child: Builder(
        builder: (pageContext) => BlocBuilder<SprintDetailCubit, SprintDetailState>(
          builder: (context, state) {
            if (state is SprintDetailLoading) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Sprint'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SprintDetailError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Sprint'),
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
                          context.read<SprintDetailCubit>().loadSprint(milestoneId, sprintId);
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is SprintDetailLoaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => EditSprintCubit(
                      updateSprintUseCase: context.read(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => DeleteSprintCubit(
                      deleteSprintUseCase: context.read(),
                    ),
                  ),
                ],
                child: _SprintDetailContent(
                  sprint: state.sprint,
                  tasks: state.tasks,
                  milestoneId: milestoneId,
                  sprintId: sprintId,
                  pageContext: pageContext,
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalle del Sprint'),
              ),
              body: const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Widget interno que muestra el contenido del detalle del sprint
/// con funcionalidad de edición y eliminación.
class _SprintDetailContent extends StatelessWidget {
  final dynamic sprint;
  final List<dynamic> tasks;
  final String milestoneId;
  final String sprintId;
  final BuildContext pageContext;

  const _SprintDetailContent({
    required this.sprint,
    required this.tasks,
    required this.milestoneId,
    required this.sprintId,
    required this.pageContext,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditSprintCubit(
            updateSprintUseCase: context.read(),
          ),
          child: EditSprintPage(
            milestoneId: milestoneId,
            sprint: sprint,
          ),
        ),
      ),
    );

    if (result != null && pageContext.mounted) {
      pageContext.read<SprintDetailCubit>().refresh(milestoneId, sprintId);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar Sprint',
      message: '¿Estás seguro de que deseas eliminar este sprint? '
          'Esta acción eliminará permanentemente el sprint, su review, '
          'retrospective y daily entries relacionados. '
          'Las tasks NO se eliminarán, solo quedarán sin sprint asignado. '
          'Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    context.read<DeleteSprintCubit>().deleteSprint(milestoneId, sprintId);
  }

  @override
  Widget build(BuildContext context) {
    final duration = sprint.durationInDays;
    final completedTasks = tasks.where((t) => t.status == 'completed').length;
    final totalTasks = tasks.length;

    return BlocListener<DeleteSprintCubit, DeleteSprintState>(
      listener: (context, state) {
        if (state is DeleteSprintSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sprint eliminado exitosamente')),
          );
        } else if (state is DeleteSprintError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Sprint'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _handleEdit(context),
            ),
            BlocBuilder<DeleteSprintCubit, DeleteSprintState>(
              builder: (context, deleteState) {
                final isDeleting = deleteState is DeleteSprintLoading;
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
            pageContext.read<SprintDetailCubit>().refresh(milestoneId, sprintId);
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
                        Text(
                          sprint.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (sprint.description != null && sprint.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            sprint.description!,
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
                              size: 20,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDate(sprint.startDate)} - ${_formatDate(sprint.endDate)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$duration ${duration == 1 ? 'día' : 'días'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (totalTasks > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Progreso: $completedTasks/$totalTasks tareas completadas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (sprint.acceptanceCriteria != null && sprint.acceptanceCriteria!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Criterios de Aceptación:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...sprint.acceptanceCriteria!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                      'Tasks del Sprint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${tasks.length} tasks',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            // Navegar a crear task con el sprint pre-seleccionado
                            final milestoneId = sprint.milestoneId;
                            final result = await Navigator.push(
                              pageContext,
                              MaterialPageRoute(
                                builder: (context) => CreateTaskPage(
                                  milestoneId: milestoneId,
                                  initialSprintId: sprintId,
                                ),
                              ),
                            );
                            if (result != null && pageContext.mounted) {
                              pageContext.read<SprintDetailCubit>().refresh(milestoneId, sprintId);
                            }
                          },
                          tooltip: 'Agregar Task al Sprint',
                        ),
                      ],
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
                            'No hay tasks en este sprint',
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
                    return TaskCard(
                      task: task,
                      completedChecklistItems: 0,
                      totalChecklistItems: 0,
                      onTap: () {
                        // Navegar al detalle de la task si es necesario
                        // Por ahora solo mostramos la lista
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
