import 'package:flutter/material.dart';
import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';

/// Widget que representa un item individual de checklist.
/// 
/// Muestra:
/// - Checkbox para marcar/desmarcar el item
/// - Descripción del item (tachada si está completado)
/// - Badge de "Requerido" si el item es obligatorio
/// - Indicador de carga mientras se actualiza
/// - Menú de opciones para editar y eliminar
class ChecklistItemWidget extends StatelessWidget {
  /// Item de checklist a mostrar
  final ChecklistItem item;

  /// Callback que se ejecuta al hacer tap en el checkbox
  /// Si es null, el checkbox está deshabilitado
  final VoidCallback? onToggle;

  /// Callback que se ejecuta al editar el item
  final VoidCallback? onEdit;

  /// Callback que se ejecuta al eliminar el item
  final VoidCallback? onDelete;

  /// Indica si el item se está actualizando (muestra un indicador de carga)
  final bool isLoading;

  /// Constructor del widget de checklist item
  const ChecklistItemWidget({
    super.key,
    required this.item,
    this.onToggle,
    this.onEdit,
    this.onDelete,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
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
              ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
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
