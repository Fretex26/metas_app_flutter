import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/enroll_in_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_enrollments.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_enrollments.states.dart';

/// Página que muestra el detalle de un Sponsored Goal.
/// 
/// Muestra información completa del objetivo patrocinado:
/// - Nombre y descripción completa
/// - Fechas de inicio y fin
/// - Categorías asociadas
/// - Información del sponsor
/// - Botón para inscribirse
/// 
/// Basado en el diseño de las imágenes proporcionadas (Project Details).
class SponsoredGoalDetailPage extends StatelessWidget {
  /// Sponsored goal a mostrar
  final SponsoredGoal goal;

  /// Constructor de la página de detalle
  const SponsoredGoalDetailPage({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SponsorEnrollmentsCubit(
        enrollInSponsoredGoalUseCase:
            context.read<EnrollInSponsoredGoalUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Objetivo'),
        ),
        body: BlocListener<SponsorEnrollmentsCubit, SponsorEnrollmentsState>(
          listener: (context, state) {
            if (state is SponsorEnrollmentsEnrolled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '¡Te has inscrito exitosamente! El proyecto aparecerá en tus proyectos.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true); // Retornar true para indicar inscripción
            }
            if (state is SponsorEnrollmentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del objetivo
                Text(
                  goal.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                // Fechas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de inicio',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                _formatDate(goal.startDate),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de fin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                _formatDate(goal.endDate),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Descripción
                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descripción',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Categorías
                if (goal.categories != null && goal.categories!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorías',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: goal.categories!.map((category) {
                              return Chip(
                                label: Text(category.name),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Información adicional
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Máximo ${goal.maxUsers} usuarios',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Verificación: Manual',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón de inscripción
                const SizedBox(height: 24),
                BlocBuilder<SponsorEnrollmentsCubit, SponsorEnrollmentsState>(
                  builder: (context, state) {
                    final isEnrolling = state is SponsorEnrollmentsEnrolling;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isEnrolling
                            ? null
                            : () {
                                _showEnrollConfirmationDialog(context);
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isEnrolling
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Inscribirse',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEnrollConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar inscripción'),
        content: const Text(
          '¿Estás seguro de que quieres inscribirte a este objetivo? '
          'El proyecto se duplicará automáticamente en tus proyectos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SponsorEnrollmentsCubit>().enrollInSponsoredGoal(
                    goal.id,
                  );
            },
            child: const Text('Inscribirse'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
