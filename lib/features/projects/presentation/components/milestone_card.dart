import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';

/// Widget que representa una tarjeta de milestone en la lista.
/// 
/// Muestra información resumida del milestone:
/// - Nombre y descripción
/// - Badge de estado (pending, in_progress, completed)
/// - Barra de progreso basada en tasks completadas (si se proporciona)
/// 
/// Al hacer tap, navega al detalle del milestone.
class MilestoneCard extends StatelessWidget {
  /// Milestone a mostrar en la tarjeta
  final Milestone milestone;

  /// Número de tasks completadas (opcional, para calcular progreso)
  final int? completedTasks;

  /// Número total de tasks (opcional, para calcular progreso)
  final int? totalTasks;

  /// Callback que se ejecuta al hacer tap en la tarjeta
  final VoidCallback onTap;

  /// Constructor de la tarjeta de milestone
  const MilestoneCard({
    super.key,
    required this.milestone,
    this.completedTasks,
    this.totalTasks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedTasks != null && totalTasks != null && totalTasks! > 0
        ? completedTasks! / totalTasks!
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
                      milestone.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: milestone.status, isCompact: true),
                ],
              ),
              if (milestone.description != null && milestone.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  milestone.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (completedTasks != null && totalTasks != null) ...[
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
                      '$completedTasks/$totalTasks',
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
}
