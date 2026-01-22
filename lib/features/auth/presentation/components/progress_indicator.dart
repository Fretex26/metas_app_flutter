import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar indicadores de progreso.
/// 
/// Puede mostrarse como:
/// - Barra de progreso lineal (por defecto)
/// - Indicador circular con porcentaje en el centro
/// 
/// Los colores cambian según el progreso:
/// - 0-33%: Azul
/// - 33-66%: Naranja
/// - 66-100%: Verde
class MyProgressIndicator extends StatelessWidget {
  /// Valor de progreso de 0.0 a 1.0 (0% a 100%)
  final double progress;

  /// Si es true, muestra un indicador circular en lugar de una barra
  final bool isCircular;

  /// Tamaño del indicador circular (solo aplica si isCircular es true)
  final double? size;

  /// Etiqueta opcional para mostrar junto al indicador
  final String? label;

  /// Constructor del indicador de progreso
  const MyProgressIndicator({
    super.key,
    required this.progress,
    this.isCircular = false,
    this.size,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 100,
            height: size ?? 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size ?? 100,
                  height: size ?? 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (label != null)
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return Colors.blue;
    } else if (progress < 0.66) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
