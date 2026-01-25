import 'package:flutter/material.dart';

/// Diálogo reutilizable para confirmar la eliminación de entidades.
/// 
/// Muestra un diálogo de confirmación con un mensaje personalizado y botones
/// para cancelar o confirmar la eliminación. El botón de confirmar tiene estilo
/// destructivo (rojo) para indicar que es una acción peligrosa.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;

  /// Mensaje de confirmación a mostrar
  final String message;

  /// Texto del botón de confirmación (por defecto: "Eliminar")
  final String confirmText;

  /// Texto del botón de cancelación (por defecto: "Cancelar")
  final String cancelText;

  /// Constructor del diálogo de confirmación
  const DeleteConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Eliminar',
    this.cancelText = 'Cancelar',
  }) : super(key: key);

  /// Muestra el diálogo de confirmación y retorna true si el usuario confirma.
  /// 
  /// [context] - Contexto de la aplicación
  /// [title] - Título del diálogo
  /// [message] - Mensaje de confirmación
  /// [confirmText] - Texto del botón de confirmación (opcional)
  /// [cancelText] - Texto del botón de cancelación (opcional)
  /// 
  /// Retorna true si el usuario confirma la eliminación, false si cancela.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Eliminar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
