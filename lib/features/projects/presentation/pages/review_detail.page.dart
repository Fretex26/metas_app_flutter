import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/presentation/components/empty_state_widget.dart';
import 'package:metas_app/features/projects/presentation/components/error_state_widget.dart';
import 'package:metas_app/features/projects/presentation/components/date_card.dart';
import 'package:metas_app/features/projects/presentation/components/progress_card.dart';
import 'package:metas_app/features/projects/presentation/components/info_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_review.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_review.states.dart';

/// Página que muestra el detalle de una review de sprint.
/// 
/// Muestra:
/// - Porcentaje de progreso (barra de progreso visual)
/// - Puntos extra otorgados
/// - Resumen (si existe)
/// - Fecha de creación
class ReviewDetailPage extends StatelessWidget {
  /// Identificador único del sprint
  final String sprintId;

  /// Constructor de la página de detalle de review
  const ReviewDetailPage({
    super.key,
    required this.sprintId,
  });


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetSprintReviewCubit(
        getSprintReviewUseCase: context.read(),
      )..loadReview(sprintId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review del Sprint'),
        ),
        body: BlocBuilder<GetSprintReviewCubit, GetSprintReviewState>(
          builder: (context, state) {
            if (state is GetSprintReviewLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetSprintReviewError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  context.read<GetSprintReviewCubit>().refresh(sprintId);
                },
              );
            }

            if (state is GetSprintReviewLoaded) {
              final review = state.review;

              if (review == null) {
                return const EmptyStateWidget(
                  icon: Icons.reviews_outlined,
                  message: 'No hay review para este sprint',
                );
              }

              return _buildReviewContent(context, review);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, Review review) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressCard(
            title: 'Progreso del Proyecto',
            progressPercentage: review.progressPercentage,
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.stars,
            title: 'Puntos Extra',
            content: '${review.extraPoints} puntos',
            customContent: Text(
              '${review.extraPoints} puntos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (review.summary != null && review.summary!.isNotEmpty) ...[
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.description,
              title: 'Resumen',
              content: review.summary!,
            ),
          ],
          const SizedBox(height: 16),
          DateCard(date: review.createdAt),
        ],
      ),
    );
  }
}
