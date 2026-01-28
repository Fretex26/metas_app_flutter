import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_review.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/create_retrospective.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_review.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_retrospective.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/create_review.page.dart';
import 'package:metas_app/features/projects/presentation/pages/create_retrospective.page.dart';
import 'package:metas_app/features/projects/presentation/pages/sprint_detail.page.dart';
import 'package:metas_app/features/projects/presentation/utils/date_formatter.dart';

/// Diálogo que muestra los sprints pendientes de review o retrospectiva.
/// 
/// Permite al usuario:
/// - Ver todos los sprints que necesitan atención
/// - Navegar directamente a crear review/retrospectiva
/// - Navegar al detalle del sprint
class PendingSprintsDialog extends StatelessWidget {
  final List<PendingSprint> pendingSprints;

  const PendingSprintsDialog({
    super.key,
    required this.pendingSprints,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sprints Pendientes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: pendingSprints.isEmpty
                  ? _buildEmptyState(context)
                  : _buildSprintsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          Text(
            '¡Todo al día!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'No hay sprints pendientes de review o retrospectiva',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSprintsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: pendingSprints.length,
      itemBuilder: (context, index) {
        final sprint = pendingSprints[index];
        return _buildSprintCard(context, sprint);
      },
    );
  }

  Widget _buildSprintCard(BuildContext context, PendingSprint sprint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleSprintTap(context, sprint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      sprint.sprintName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChips(context, sprint),
                ],
              ),
              const SizedBox(height: 8),
              // Información del proyecto y milestone
              Text(
                sprint.projectName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                sprint.milestoneName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 12),
              // Fecha de finalización
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Finalizó: ${DateFormatter.formatDate(sprint.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChips(BuildContext context, PendingSprint sprint) {
    return Wrap(
      spacing: 4,
      children: [
        if (sprint.needsReview)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Review',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (sprint.needsRetrospective)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Retrospectiva',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void _handleSprintTap(BuildContext context, PendingSprint sprint) {
    if (sprint.needsBoth) {
      // Si necesita ambas, mostrar diálogo para elegir (no cerrar el diálogo principal aún)
      _showActionDialog(context, sprint);
    } else {
      // Para los demás casos, cerrar el diálogo primero y luego navegar
      Navigator.of(context).pop();
      
      if (sprint.needsReview) {
        // Navegar directamente a crear review
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => CreateReviewCubit(
                createReviewUseCase: context.read<CreateReviewUseCase>(),
              ),
              child: CreateReviewPage(sprintId: sprint.sprintId),
            ),
          ),
        );
      } else if (sprint.needsRetrospective) {
        // Navegar directamente a crear retrospectiva
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => CreateRetrospectiveCubit(
                createRetrospectiveUseCase: context.read<CreateRetrospectiveUseCase>(),
              ),
              child: CreateRetrospectivePage(sprintId: sprint.sprintId),
            ),
          ),
        );
      } else {
        // Si ya tiene ambas (caso raro), navegar al detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SprintDetailPage(
              projectId: sprint.projectId,
              milestoneId: sprint.milestoneId,
              sprintId: sprint.sprintId,
            ),
          ),
        );
      }
    }
  }

  void _showActionDialog(BuildContext context, PendingSprint sprint) {
    // Guardar referencias a los use cases y obtener el root navigator antes de cerrar el diálogo
    final createReviewUseCase = context.read<CreateReviewUseCase>();
    final createRetrospectiveUseCase = context.read<CreateRetrospectiveUseCase>();
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Función auxiliar para cerrar ambos diálogos y navegar
        void navigateAndClose(Widget page) {
          Navigator.of(dialogContext).pop(); // Cerrar diálogo de acción
          Navigator.of(context).pop(); // Cerrar diálogo principal
          // Usar Future.microtask para asegurar que la navegación ocurra después del cierre
          // y usar el root navigator que siempre está disponible
          Future.microtask(() {
            rootNavigator.push(
              MaterialPageRoute(builder: (_) => page),
            );
          });
        }
        
        return AlertDialog(
          title: Text(sprint.sprintName),
          content: const Text(
            'Este sprint necesita tanto review como retrospectiva. ¿Qué deseas crear primero?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                navigateAndClose(
                  BlocProvider(
                    create: (_) => CreateReviewCubit(
                      createReviewUseCase: createReviewUseCase,
                    ),
                    child: CreateReviewPage(sprintId: sprint.sprintId),
                  ),
                );
              },
              child: const Text('Review'),
            ),
            TextButton(
              onPressed: () {
                navigateAndClose(
                  BlocProvider(
                    create: (_) => CreateRetrospectiveCubit(
                      createRetrospectiveUseCase: createRetrospectiveUseCase,
                    ),
                    child: CreateRetrospectivePage(sprintId: sprint.sprintId),
                  ),
                );
              },
              child: const Text('Retrospectiva'),
            ),
            TextButton(
              onPressed: () {
                navigateAndClose(
                  SprintDetailPage(
                    projectId: sprint.projectId,
                    milestoneId: sprint.milestoneId,
                    sprintId: sprint.sprintId,
                  ),
                );
              },
              child: const Text('Ver Detalle'),
            ),
          ],
        );
      },
    );
  }
}
