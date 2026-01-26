import 'package:flutter/material.dart';
import 'package:metas_app/features/projects/domain/entities/sprint.dart';

/// Widget que representa una tarjeta de sprint en la lista.
/// 
/// Muestra información resumida del sprint:
/// - Nombre y descripción
/// - Fechas de inicio y fin
/// - Duración en días
/// - Número de tasks (si se proporciona)
/// 
/// Al hacer tap, navega al detalle del sprint.
class SprintCard extends StatelessWidget {
  /// Sprint a mostrar en la tarjeta
  final Sprint sprint;

  /// Número de tasks asociadas (opcional)
  final int? taskCount;

  /// Callback que se ejecuta al hacer tap en la tarjeta
  final VoidCallback onTap;

  /// Constructor de la tarjeta de sprint
  const SprintCard({
    super.key,
    required this.sprint,
    this.taskCount,
    required this.onTap,
  });

  /// Formatea una fecha para mostrarla en formato corto
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final duration = sprint.durationInDays;
    final isValidDuration = sprint.isValidDuration;

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
                      sprint.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isValidDuration)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '>28 días',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (sprint.description != null && sprint.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sprint.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(sprint.startDate)} - ${_formatDate(sprint.endDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$duration ${duration == 1 ? 'día' : 'días'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (taskCount != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.task,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$taskCount ${taskCount == 1 ? 'tarea' : 'tareas'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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
}
