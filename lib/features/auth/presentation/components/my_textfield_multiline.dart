import 'package:flutter/material.dart';

/// Widget reutilizable de campo de texto multilínea.
/// 
/// Similar a [MyTextField] pero permite múltiples líneas de texto.
/// Útil para descripciones y textos largos. Sigue el estilo de diseño
/// de la aplicación con bordes redondeados y colores del tema.
class MyTextFieldMultiline extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;

  /// Texto de ayuda (placeholder)
  final String hintText;

  /// Número máximo de líneas visibles (por defecto: 3)
  final int maxLines;

  /// Indica si el campo está habilitado
  final bool enabled;

  /// Constructor del campo de texto multilínea
  const MyTextFieldMultiline({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 3,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
      ),
    );
  }
}
