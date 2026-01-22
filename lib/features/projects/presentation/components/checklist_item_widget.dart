import 'package:flutter/material.dart';
import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';

/// Widget que representa un item individual de checklist.
/// 
/// Muestra:
/// - Checkbox para marcar/desmarcar el item
/// - Descripción del item (tachada si está completado)
/// - Badge de "Requerido" si el item es obligatorio
/// - Indicador de carga mientras se actualiza
class ChecklistItemWidget extends StatelessWidget {
  /// Item de checklist a mostrar
  final ChecklistItem item;

  /// Callback que se ejecuta al hacer tap en el checkbox
  /// Si es null, el checkbox está deshabilitado
  final VoidCallback? onToggle;

  /// Indica si el item se está actualizando (muestra un indicador de carga)
  final bool isLoading;

  /// Constructor del widget de checklist item
  const ChecklistItemWidget({
    super.key,
    required this.item,
    this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: ListTile(
        leading: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Checkbox(
                value: item.isChecked,
                onChanged: onToggle != null ? (_) => onToggle!() : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
        title: Text(
          item.description,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.primary,
            fontWeight: item.isRequired ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: item.isRequired
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Text(
                  'Requerido',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
