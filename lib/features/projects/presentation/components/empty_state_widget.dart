import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un estado vacío.
/// 
/// Muestra un icono grande y un mensaje cuando no hay datos disponibles.
class EmptyStateWidget extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;

  /// Mensaje a mostrar
  final String message;

  /// Tamaño del icono (por defecto: 64)
  final double iconSize;

  /// Constructor del widget de estado vacío
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
