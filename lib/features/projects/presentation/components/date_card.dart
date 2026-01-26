import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una fecha en un card.
/// 
/// Muestra un icono de calendario y la fecha formateada.
class DateCard extends StatelessWidget {
  /// Fecha a mostrar
  final DateTime date;

  /// Prefijo del texto (por defecto: 'Creada el')
  final String prefix;

  /// Constructor del card de fecha
  const DateCard({
    super.key,
    required this.date,
    this.prefix = 'Creada el',
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              '$prefix ${_formatDate(date)}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
