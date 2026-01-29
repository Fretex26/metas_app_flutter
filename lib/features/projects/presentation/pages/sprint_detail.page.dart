import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_task_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/projects/presentation/components/task_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/create_task.page.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_sprint.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/sprint_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/sprint_detail.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_sprint.page.dart';
import 'package:metas_app/features/projects/presentation/pages/create_review.page.dart';
import 'package:metas_app/features/projects/presentation/pages/review_detail.page.dart';
import 'package:metas_app/features/projects/presentation/pages/create_retrospective.page.dart';
import 'package:metas_app/features/projects/presentation/pages/retrospective_detail.page.dart';
import 'package:metas_app/features/projects/presentation/pages/task_detail.page.dart';
import 'package:metas_app/features/projects/presentation/components/review_summary_card.dart';
import 'package:metas_app/features/projects/presentation/components/retrospective_summary_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_review.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_review.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_retrospective.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_retrospective.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_review.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_retrospective.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_daily_entry_by_date.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_daily_entry_by_date.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_daily_entry.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/create_daily_entry.page.dart';
import 'package:metas_app/features/projects/presentation/pages/daily_entries_list.page.dart';

/// Página que muestra el detalle completo de un sprint.
/// 
/// Muestra:
/// - Información del sprint (nombre, descripción, fechas, duración)
/// - Lista de tasks asociadas al sprint
/// - Pull-to-refresh para actualizar
/// - Opciones para editar y eliminar el sprint
class SprintDetailPage extends StatelessWidget {
  /// Identificador único del proyecto (para navegación)
  final String projectId;

  /// Identificador único del milestone (para navegación)
  final String milestoneId;

  /// Identificador único del sprint a mostrar
  final String sprintId;

  /// Constructor de la página de detalle de sprint
  const SprintDetailPage({
    super.key,
    required this.projectId,
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
                  BlocProvider(
                    create: (context) => GetSprintReviewCubit(
                      getSprintReviewUseCase: context.read(),
                    )..loadReview(sprintId),
                  ),
                  BlocProvider(
                    create: (context) => GetSprintRetrospectiveCubit(
                      getSprintRetrospectiveUseCase: context.read(),
                    )..loadRetrospective(sprintId),
                  ),
                  BlocProvider(
                    create: (context) => GetDailyEntryByDateCubit(
                      getDailyEntryByDateUseCase: context.read(),
                    )..loadDailyEntryByDate(DateTime.now(), sprintId),
                  ),
                ],
                child: _SprintDetailContent(
                  sprint: state.sprint,
                  tasks: state.tasks,
                  projectId: projectId,
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
class _SprintDetailContent extends StatefulWidget {
  final dynamic sprint;
  final List<dynamic> tasks;
  final String projectId;
  final String milestoneId;
  final String sprintId;
  final BuildContext pageContext;

  const _SprintDetailContent({
    required this.sprint,
    required this.tasks,
    required this.projectId,
    required this.milestoneId,
    required this.sprintId,
    required this.pageContext,
  });

  @override
  State<_SprintDetailContent> createState() => _SprintDetailContentState();
}

class _SprintDetailContentState extends State<_SprintDetailContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refrescar la entrada diaria cuando la página se vuelve a mostrar
    // Solo refrescar si no está en estado de carga para evitar refrescos innecesarios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<GetDailyEntryByDateCubit>().state;
        // Solo refrescar si no está cargando y no es un estado de error reciente
        if (state is! GetDailyEntryByDateLoading) {
          context.read<GetDailyEntryByDateCubit>().refresh(DateTime.now(), widget.sprintId);
        }
      }
    });
  }

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
            milestoneId: widget.milestoneId,
            sprint: widget.sprint,
          ),
        ),
      ),
    );

    if (result != null && widget.pageContext.mounted) {
      widget.pageContext.read<SprintDetailCubit>().refresh(widget.milestoneId, widget.sprintId);
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

    context.read<DeleteSprintCubit>().deleteSprint(widget.milestoneId, widget.sprintId);
  }

  bool _isSprintFinished() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(widget.sprint.endDate.year, widget.sprint.endDate.month, widget.sprint.endDate.day);
    // El sprint está finalizado si la fecha de fin es anterior o igual a hoy
    return endDate.isBefore(today) || endDate == today;
  }
  
  @override
  Widget build(BuildContext context) {
    final duration = widget.sprint.durationInDays;
    final completedTasks = widget.tasks.where((t) => t.status == 'completed').length;
    final totalTasks = widget.tasks.length;
    final isFinished = _isSprintFinished();

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
            widget.pageContext.read<SprintDetailCubit>().refresh(widget.milestoneId, widget.sprintId);
            // También refrescar la entrada diaria
            context.read<GetDailyEntryByDateCubit>().refresh(DateTime.now(), widget.sprintId);
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
                          widget.sprint.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (widget.sprint.description != null && widget.sprint.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.sprint.description!,
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
                              '${_formatDate(widget.sprint.startDate)} - ${_formatDate(widget.sprint.endDate)}',
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
                        if (widget.sprint.acceptanceCriteria != null && widget.sprint.acceptanceCriteria!.isNotEmpty) ...[
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
                          ...widget.sprint.acceptanceCriteria!.entries.map((entry) {
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
                          '${widget.tasks.length} tasks',
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
                            final milestoneId = widget.sprint.milestoneId;
                            final result = await Navigator.push(
                              widget.pageContext,
                              MaterialPageRoute(
                                builder: (context) => CreateTaskPage(
                                  milestoneId: milestoneId,
                                  initialSprintId: widget.sprintId,
                                ),
                              ),
                            );
                            if (result != null && widget.pageContext.mounted) {
                              widget.pageContext.read<SprintDetailCubit>().refresh(milestoneId, widget.sprintId);
                            }
                          },
                          tooltip: 'Agregar Task al Sprint',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.tasks.isEmpty)
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
                  ...widget.tasks.map((task) {
                    return TaskCard(
                      task: task,
                      completedChecklistItems: 0,
                      totalChecklistItems: 0,
                      onTap: () async {
                        // Obtener los use cases necesarios para TaskDetailPage
                        final getTaskByIdUseCase = context.read<GetTaskByIdUseCase>();
                        final getChecklistItemsUseCase = context.read<GetChecklistItemsUseCase>();
                        final createChecklistItemUseCase = context.read<CreateChecklistItemUseCase>();
                        final updateChecklistItemUseCase = context.read<UpdateChecklistItemUseCase>();
                        
                        // Navegar al detalle de la task
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (_) => TaskDetailCubit(
                                    getTaskByIdUseCase: getTaskByIdUseCase,
                                    getChecklistItemsUseCase: getChecklistItemsUseCase,
                                  )..loadTask(widget.milestoneId, task.id),
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
                                projectId: widget.projectId,
                                milestoneId: widget.milestoneId,
                                taskId: task.id,
                              ),
                            ),
                          ),
                        );
                        
                        // Refrescar el sprint después de regresar
                        if (widget.pageContext.mounted) {
                          widget.pageContext.read<SprintDetailCubit>().refresh(widget.milestoneId, widget.sprintId);
                        }
                      },
                    );
                  }),
                const SizedBox(height: 32),
                _buildDailyEntrySection(context, widget.sprintId),
                if (isFinished) ...[
                  const SizedBox(height: 32),
                  _buildReviewSection(context, widget.sprintId),
                  const SizedBox(height: 24),
                  _buildRetrospectiveSection(context, widget.sprintId),
                ] else ...[
                  const SizedBox(height: 32),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Las reviews y retrospectivas solo se pueden realizar al finalizar el sprint',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, String sprintId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Review del Sprint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            BlocBuilder<GetSprintReviewCubit, GetSprintReviewState>(
              builder: (context, state) {
                if (state is GetSprintReviewLoaded && state.review != null) {
                  return TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailPage(sprintId: sprintId),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<GetSprintReviewCubit>().refresh(sprintId);
                      }
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver Review'),
                  );
                } else {
                  return TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => CreateReviewCubit(
                              createReviewUseCase: context.read(),
                            ),
                            child: CreateReviewPage(sprintId: sprintId),
                          ),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<GetSprintReviewCubit>().refresh(sprintId);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Review'),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<GetSprintReviewCubit, GetSprintReviewState>(
          builder: (context, state) {
            if (state is GetSprintReviewLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GetSprintReviewError) {
              return Card(
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error al cargar review: ${state.message}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            }
            if (state is GetSprintReviewLoaded) {
              if (state.review == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reviews_outlined,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No hay review para este sprint. Crea una para registrar el progreso y puntos extra.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ReviewSummaryCard(review: state.review!);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildRetrospectiveSection(BuildContext context, String sprintId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Retrospectiva del Sprint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            BlocBuilder<GetSprintRetrospectiveCubit, GetSprintRetrospectiveState>(
              builder: (context, state) {
                if (state is GetSprintRetrospectiveLoaded && state.retrospective != null) {
                  return TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RetrospectiveDetailPage(sprintId: sprintId),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<GetSprintRetrospectiveCubit>().refresh(sprintId);
                      }
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver Retrospectiva'),
                  );
                } else {
                  return TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => CreateRetrospectiveCubit(
                              createRetrospectiveUseCase: context.read(),
                            ),
                            child: CreateRetrospectivePage(sprintId: sprintId),
                          ),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<GetSprintRetrospectiveCubit>().refresh(sprintId);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Retrospectiva'),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<GetSprintRetrospectiveCubit, GetSprintRetrospectiveState>(
          builder: (context, state) {
            if (state is GetSprintRetrospectiveLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GetSprintRetrospectiveError) {
              return Card(
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error al cargar retrospectiva: ${state.message}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            }
            if (state is GetSprintRetrospectiveLoaded) {
              if (state.retrospective == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No hay retrospectiva para este sprint. Crea una para analizar lo que salió bien, lo que salió mal y proponer mejoras.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RetrospectiveSummaryCard(retrospective: state.retrospective!);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDailyEntrySection(BuildContext context, String sprintId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Entrada Diaria',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyEntriesListPage(),
                      ),
                    );
                  },
                  tooltip: 'Ver todas las entradas diarias',
                ),
                BlocBuilder<GetDailyEntryByDateCubit, GetDailyEntryByDateState>(
                  builder: (context, state) {
                    if (state is GetDailyEntryByDateLoaded && state.dailyEntry != null) {
                      return TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ya has completado tu entrada diaria de hoy'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Completado'),
                      );
                    } else {
                      return TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => CreateDailyEntryCubit(
                                  createDailyEntryUseCase: context.read(),
                                ),
                                child: CreateDailyEntryPage(
                                  sprintId: sprintId,
                                ),
                              ),
                            ),
                          );
                          if (result != null && context.mounted) {
                            // Esperar un poco para asegurar que la entrada se haya guardado
                            await Future.delayed(const Duration(milliseconds: 500));
                            if (context.mounted) {
                              context.read<GetDailyEntryByDateCubit>().refresh(DateTime.now(), widget.sprintId);
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Daily'),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
            BlocBuilder<GetDailyEntryByDateCubit, GetDailyEntryByDateState>(
              builder: (context, state) {
                if (state is GetDailyEntryByDateLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GetDailyEntryByDateError) {
                  return Card(
                    color: Colors.red.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error al cargar entrada diaria: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }
                if (state is GetDailyEntryByDateLoaded) {
                  if (state.dailyEntry == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No has creado tu entrada diaria de hoy. Crea una para registrar tu progreso y recibir energía como recompensa.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Mostrar resumen de la entrada diaria de hoy
              final entry = state.dailyEntry!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Entrada diaria completada',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ayer: ${entry.notesYesterday}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hoy: ${entry.notesToday}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
