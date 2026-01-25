import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';

/// Widget que representa una tarjeta de task en la lista.
/// 
/// Muestra información resumida de la task:
/// - Nombre y descripción
/// - Badge de estado (pending, in_progress, completed)
/// - Fechas de inicio y fin
/// - Puntos de incentivo (si tiene)
/// - Barra de progreso basada en checklist items completados (si se proporciona)
/// 
/// Al hacer tap, navega al detalle de la task.
class TaskCard extends StatelessWidget {
  /// Task a mostrar en la tarjeta
  final Task task;

  /// Número de checklist items completados (opcional, para calcular progreso)
  final int? completedChecklistItems;

  /// Número total de checklist items (opcional, para calcular progreso)
  final int? totalChecklistItems;

  /// Callback que se ejecuta al hacer tap en la tarjeta
  final VoidCallback onTap;

  /// Constructor de la tarjeta de task
  const TaskCard({
    super.key,
    required this.task,
    this.completedChecklistItems,
    this.totalChecklistItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedChecklistItems != null &&
            totalChecklistItems != null &&
            totalChecklistItems! > 0
        ? completedChecklistItems! / totalChecklistItems!
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: task.status, isCompact: true),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(task.startDate)} - ${_formatDate(task.endDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  if (task.incentivePoints != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.incentivePoints} pts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (completedChecklistItems != null && totalChecklistItems != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress < 0.33
                                ? Colors.blue
                                : progress < 0.66
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedChecklistItems/$totalChecklistItems',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
