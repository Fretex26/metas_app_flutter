import 'package:flutter/material.dart';
import 'package:metas_app/features/projects/domain/entities/review.dart';

/// Widget reutilizable para mostrar un resumen de review en un card compacto.
/// 
/// Muestra progreso, puntos extra y resumen (si existe).
/// Útil para mostrar en listas o vistas resumidas.
class ReviewSummaryCard extends StatelessWidget {
  /// Review a mostrar
  final Review review;

  /// Si es true, muestra el resumen completo. Si es false, solo muestra 2 líneas.
  final bool showFullSummary;

  /// Constructor del card de resumen de review
  const ReviewSummaryCard({
    super.key,
    required this.review,
    this.showFullSummary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso: ${review.progressPercentage}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: review.progressPercentage / 100,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${review.extraPoints}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (review.summary != null && review.summary!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.summary!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                maxLines: showFullSummary ? null : 2,
                overflow: showFullSummary ? null : TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
