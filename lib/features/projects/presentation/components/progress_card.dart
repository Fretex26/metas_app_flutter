import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un progreso en un card.
/// 
/// Muestra un título, una barra de progreso y el porcentaje.
class ProgressCard extends StatelessWidget {
  /// Título del card
  final String title;

  /// Porcentaje de progreso (0-100)
  final int progressPercentage;

  /// Altura mínima de la barra de progreso (por defecto: 20)
  final double minHeight;

  /// Constructor del card de progreso
  const ProgressCard({
    super.key,
    required this.title,
    required this.progressPercentage,
    this.minHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progressPercentage / 100,
                    minHeight: minHeight,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$progressPercentage%',
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
      ),
    );
  }
}
