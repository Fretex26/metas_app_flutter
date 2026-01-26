import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/presentation/components/empty_state_widget.dart';
import 'package:metas_app/features/projects/presentation/components/error_state_widget.dart';
import 'package:metas_app/features/projects/presentation/components/date_card.dart';
import 'package:metas_app/features/projects/presentation/components/info_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_retrospective.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_retrospective.states.dart';

/// Página que muestra el detalle de una retrospectiva de sprint.
/// 
/// Muestra:
/// - Lo que salió bien
/// - Lo que salió mal
/// - Mejoras propuestas (si existe)
/// - Indicador de si es pública o privada
/// - Fecha de creación
class RetrospectiveDetailPage extends StatelessWidget {
  /// Identificador único del sprint
  final String sprintId;

  /// Constructor de la página de detalle de retrospectiva
  const RetrospectiveDetailPage({
    super.key,
    required this.sprintId,
  });


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetSprintRetrospectiveCubit(
        getSprintRetrospectiveUseCase: context.read(),
      )..loadRetrospective(sprintId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Retrospectiva del Sprint'),
        ),
        body: BlocBuilder<GetSprintRetrospectiveCubit, GetSprintRetrospectiveState>(
          builder: (context, state) {
            if (state is GetSprintRetrospectiveLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetSprintRetrospectiveError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  context.read<GetSprintRetrospectiveCubit>().refresh(sprintId);
                },
              );
            }

            if (state is GetSprintRetrospectiveLoaded) {
              final retrospective = state.retrospective;

              if (retrospective == null) {
                return const EmptyStateWidget(
                  icon: Icons.history,
                  message: 'No hay retrospectiva para este sprint',
                );
              }

              return _buildRetrospectiveContent(context, retrospective);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRetrospectiveContent(BuildContext context, Retrospective retrospective) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: 'Lo que salió bien',
            content: retrospective.whatWentWell,
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.cancel_outlined,
            iconColor: Colors.red,
            title: 'Lo que salió mal',
            content: retrospective.whatWentWrong,
          ),
          if (retrospective.improvements != null && retrospective.improvements!.isNotEmpty) ...[
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.lightbulb_outline,
              iconColor: Colors.amber,
              title: 'Mejoras propuestas',
              content: retrospective.improvements!,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    retrospective.isPublic ? Icons.public : Icons.lock,
                    color: retrospective.isPublic ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    retrospective.isPublic ? 'Pública' : 'Privada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DateCard(date: retrospective.createdAt),
        ],
      ),
    );
  }
}
