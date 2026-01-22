import 'package:flutter/material.dart';

/// Widget reutilizable para seleccionar fechas.
/// 
/// Muestra un campo de texto que al hacer tap abre un DatePicker.
/// Sigue el estilo de diseño de la aplicación con bordes redondeados
/// y colores del tema.
class MyDatePicker extends StatelessWidget {
  /// Fecha actualmente seleccionada
  final DateTime? selectedDate;

  /// Callback que se ejecuta cuando se selecciona una fecha
  final ValueChanged<DateTime?> onDateSelected;

  /// Texto de la etiqueta del campo
  final String labelText;

  /// Texto de ayuda (placeholder)
  final String? hintText;

  /// Primera fecha disponible para seleccionar
  final DateTime? firstDate;

  /// Última fecha disponible para seleccionar
  final DateTime? lastDate;

  /// Si es true, exige que firstDate no sea null antes de abrir el selector.
  /// Útil para rangos (ej. fecha fin depende de fecha inicio).
  final bool requireFirstDate;

  /// Mensaje a mostrar cuando falta la fecha inicial en modo requireFirstDate.
  final String? missingFirstDateMessage;

  /// Constructor del selector de fechas
  const MyDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    required this.labelText,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.requireFirstDate = false,
    this.missingFirstDateMessage,
  });

  Future<void> _selectDate(BuildContext context) async {
    // Si se requiere una fecha inicial y no está presente, informamos y salimos.
    if (requireFirstDate && firstDate == null) {
      final message = missingFirstDateMessage ?? 'Selecciona primero la fecha inicial';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // Asegura que initialDate nunca sea anterior a firstDate para evitar assertions.
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);

    // Si requireFirstDate está activo, la fecha mínima es un día después de firstDate.
    final DateTime baseFirstDate = firstDate ?? todayDate;
    final DateTime effectiveFirstDate = requireFirstDate
        ? DateTime(baseFirstDate.year, baseFirstDate.month, baseFirstDate.day).add(const Duration(days: 1))
        : DateTime(baseFirstDate.year, baseFirstDate.month, baseFirstDate.day);

    // Si no se pasa lastDate, permitimos fechas futuras amplias.
    final DateTime defaultLast = DateTime(2100);
    DateTime effectiveLastDate = lastDate ?? defaultLast;
    if (effectiveLastDate.isBefore(effectiveFirstDate)) {
      effectiveLastDate = effectiveFirstDate;
    }

    DateTime initial = selectedDate ?? effectiveFirstDate;
    if (initial.isBefore(effectiveFirstDate)) {
      initial = effectiveFirstDate.isAfter(todayDate) ? effectiveFirstDate : todayDate;
    }
    if (initial.isAfter(effectiveLastDate)) {
      initial = effectiveLastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : '',
          ),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            labelText: labelText,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            hintText: hintText ?? 'Selecciona una fecha',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            fillColor: Theme.of(context).colorScheme.secondary,
            filled: true,
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
