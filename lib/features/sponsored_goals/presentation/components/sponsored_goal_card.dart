import 'package:flutter/material.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';

/// Widget que representa una tarjeta de Sponsored Goal en la lista.
/// 
/// Muestra información resumida del sponsored goal:
/// - Nombre y descripción
/// - Fechas de inicio y fin
/// - Categorías asociadas
/// - Número máximo de usuarios
/// - Botón para inscribirse o ver detalles
/// 
/// Basado en el diseño de las imágenes proporcionadas, con estilo moderno y limpio.
class SponsoredGoalCard extends StatelessWidget {
  /// Sponsored goal a mostrar en la tarjeta
  final SponsoredGoal goal;

  /// Callback que se ejecuta al hacer tap en "Ver detalles"
  final VoidCallback? onViewDetails;

  /// Callback que se ejecuta al hacer tap en "Inscribirse"
  final VoidCallback? onEnroll;

  /// Indica si el usuario ya está inscrito
  final bool isEnrolled;

  /// Constructor de la tarjeta de sponsored goal
  const SponsoredGoalCard({
    super.key,
    required this.goal,
    this.onViewDetails,
    this.onEnroll,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del objetivo
            Text(
              goal.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Descripción
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Fechas
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(goal.startDate)} - ${_formatDate(goal.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            // Categorías
            if (goal.categories != null && goal.categories!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: goal.categories!.take(3).map((category) {
                  return Chip(
                    label: Text(
                      category.name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            // Información adicional
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Máximo ${goal.maxUsers} usuarios',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            // Botones de acción
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('Ver detalles'),
                  ),
                if (onEnroll != null && !isEnrolled)
                  FilledButton(
                    onPressed: onEnroll,
                    child: const Text('Inscribirse'),
                  )
                else if (isEnrolled)
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Inscrito'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
