import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un estado de error.
/// 
/// Muestra un mensaje de error y un botón para reintentar.
class ErrorStateWidget extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;

  /// Callback que se ejecuta al presionar el botón de reintentar
  final VoidCallback onRetry;

  /// Constructor del widget de estado de error
  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
