import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/my_dropdown.dart';

class MyRoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  
  const MyRoleDropdown({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MyDropdown<String>(
      value: value,
      onChanged: onChanged,
      labelText: 'Propósito:',
      hintText: 'Selecciona un propósito',
      items: [
        DropdownMenuItem(
          value: 'user',
          child: Text(
            'Crear proyectos (rol user)',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        DropdownMenuItem(
          value: 'sponsor',
          child: Text(
            'Patrocinar proyectos (rol sponsor)',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
