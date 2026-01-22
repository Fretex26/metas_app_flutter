import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/presentation/components/checklist_item_widget.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/task_detail.states.dart';
import 'package:metas_app/features/projects/presentation/pages/create_checklist_item.page.dart';

/// Página que muestra el detalle completo de una task.
/// 
/// Muestra:
/// - Información de la task (nombre, descripción, estado, fechas, puntos de incentivo)
/// - Lista de checklist items con checkboxes interactivos
/// - Pull-to-refresh para actualizar (recarga task y checklist items)
/// - FAB para crear nuevo checklist item
/// 
/// Al marcar/desmarcar checklist items, el estado de la task se actualiza automáticamente
/// en el backend según las reglas de dependencias.
class TaskDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Task'),
      ),
      body: BlocBuilder<TaskDetailCubit, TaskDetailState>(
        builder: (context, taskState) {
          if (taskState is TaskDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskState is TaskDetailError) {
            return Center(
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
                      context.read<TaskDetailCubit>().loadTask(milestoneId, taskId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (taskState is TaskDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<TaskDetailCubit>().refreshTask(milestoneId, taskId);
                context.read<ChecklistCubit>().loadChecklistItems(taskId);
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
                                    taskState.task.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: taskState.task.status),
                              ],
                            ),
                            if (taskState.task.description != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                taskState.task.description!,
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
                                  '${_formatDate(taskState.task.startDate)} - ${_formatDate(taskState.task.endDate)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                                if (taskState.task.incentivePoints != null) ...[
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${taskState.task.incentivePoints} pts',
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
                                onToggle: () {
                                  context.read<ChecklistCubit>().toggleChecklistItem(taskId, item);
                                },
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final checklistCubit = context.read<ChecklistCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: checklistCubit,
                child: CreateChecklistItemPage(taskId: taskId),
              ),
            ),
          ).then((_) {
            context.read<ChecklistCubit>().loadChecklistItems(taskId);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
