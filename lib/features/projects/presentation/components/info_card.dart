import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar información en un card.
/// 
/// Muestra un icono, un título y contenido opcional.
class InfoCard extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;

  /// Color del icono
  final Color? iconColor;

  /// Título del card
  final String title;

  /// Contenido del card (opcional)
  final String? content;

  /// Widget personalizado para el contenido (opcional, tiene prioridad sobre content)
  final Widget? customContent;

  /// Constructor del card de información
  const InfoCard({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.content,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: effectiveIconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (customContent != null) ...[
              const SizedBox(height: 8),
              customContent!,
            ] else if (content != null && content!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                content!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
