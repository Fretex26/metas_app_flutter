import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/progress_indicator.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';

/// Widget que representa una tarjeta de proyecto en la lista.
/// 
/// Muestra información resumida del proyecto:
/// - Nombre y descripción
/// - Badge de estado (pending, in_progress, completed)
/// - Barra de progreso basada en tasks completadas
/// - Fecha límite si está disponible
/// 
/// Al hacer tap, navega al detalle del proyecto.
class ProjectCard extends StatelessWidget {
  /// Proyecto a mostrar en la tarjeta
  final Project project;

  /// Progreso del proyecto (opcional, se muestra si está disponible)
  final ProjectProgress? progress;

  /// Callback que se ejecuta al hacer tap en la tarjeta
  final VoidCallback onTap;

  /// Constructor de la tarjeta de proyecto
  const ProjectCard({
    super.key,
    required this.project,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress != null && progress!.totalTasks > 0
        ? progress!.completedTasks / progress!.totalTasks
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
                      project.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: project.status ?? 'pending'),
                ],
              ),
              if (project.description != null && project.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: 12),
                MyProgressIndicator(
                  progress: progressValue,
                  label: '${progress!.completedTasks}/${progress!.totalTasks} tareas',
                ),
              ],
              if (project.finalDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fecha límite: ${_formatDate(project.finalDate!)}',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
