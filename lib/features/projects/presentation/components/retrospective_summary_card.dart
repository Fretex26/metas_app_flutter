import 'package:flutter/material.dart';
import 'package:metas_app/features/projects/domain/entities/retrospective.dart';

/// Widget reutilizable para mostrar un resumen de retrospectiva en un card compacto.
/// 
/// Muestra si es pública/privada, lo que salió bien y lo que salió mal.
/// Útil para mostrar en listas o vistas resumidas.
class RetrospectiveSummaryCard extends StatelessWidget {
  /// Retrospectiva a mostrar
  final Retrospective retrospective;

  /// Si es true, muestra el contenido completo. Si es false, solo muestra 2 líneas.
  final bool showFullContent;

  /// Constructor del card de resumen de retrospectiva
  const RetrospectiveSummaryCard({
    super.key,
    required this.retrospective,
    this.showFullContent = false,
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
                Icon(
                  retrospective.isPublic ? Icons.public : Icons.lock,
                  color: retrospective.isPublic ? Colors.green : Colors.grey,
                  size: 20,
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    retrospective.whatWentWell,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    maxLines: showFullContent ? null : 2,
                    overflow: showFullContent ? null : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    retrospective.whatWentWrong,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    maxLines: showFullContent ? null : 2,
                    overflow: showFullContent ? null : TextOverflow.ellipsis,
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
