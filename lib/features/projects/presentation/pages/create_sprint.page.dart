import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_sprint.states.dart';

/// Página para crear un nuevo sprint dentro de un milestone.
/// 
/// Muestra un formulario con:
/// - Nombre del sprint (requerido)
/// - Descripción (opcional)
/// - Fechas de inicio y fin (requeridas, la de fin debe ser posterior a la de inicio)
/// - Criterios de aceptación (opcional, JSON)
/// - Formularios dinámicos para recursos disponibles y necesarios
/// 
/// Valida que el período no exceda 28 días antes de enviar.
/// Al crear exitosamente, navega de vuelta y actualiza la lista de sprints.
class CreateSprintPage extends StatefulWidget {
  /// Identificador único del milestone al que pertenecerá el sprint
  final String milestoneId;

  /// Constructor de la página de creación de sprint
  const CreateSprintPage({super.key, required this.milestoneId});

  @override
  State<CreateSprintPage> createState() => _CreateSprintPageState();
}

class _CreateSprintPageState extends State<CreateSprintPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _acceptanceCriteria;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las fechas de inicio y fin son obligatorias')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio')),
      );
      return;
    }

    // Validar que el período no exceda 28 días
    final daysDiff = _endDate!.difference(_startDate!).inDays + 1;
    if (daysDiff > 28) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El período del sprint no debe exceder 4 semanas (28 días)'),
        ),
      );
      return;
    }

    final dto = CreateSprintDto(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      startDate:
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
      endDate:
          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
      acceptanceCriteria: _acceptanceCriteria,
      resourcesAvailable: _resourcesAvailable,
      resourcesNeeded: _resourcesNeeded,
    );

    context.read<CreateSprintCubit>().createSprint(widget.milestoneId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Sprint'),
      ),
      body: BlocConsumer<CreateSprintCubit, CreateSprintState>(
        listener: (context, state) {
          if (state is CreateSprintSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sprint creado exitosamente')),
            );
          } else if (state is CreateSprintError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateSprintLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _nameController,
                    hintText: 'Nombre del sprint *',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyTextFieldMultiline(
                    controller: _descriptionController,
                    hintText: 'Descripción',
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyDatePicker(
                    selectedDate: _startDate,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                        // Si la fecha de fin es anterior a la nueva fecha de inicio, resetearla
                        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                          _endDate = null;
                        }
                      });
                    },
                    labelText: 'Fecha de inicio *',
                    hintText: 'Selecciona una fecha',
                  ),
                  const SizedBox(height: 16),
                  MyDatePicker(
                    selectedDate: _endDate,
                    onDateSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                    labelText: 'Fecha de fin *',
                    hintText: 'Selecciona una fecha',
                    firstDate: _startDate,
                    requireFirstDate: true,
                    missingFirstDateMessage: 'Selecciona primero la fecha de inicio',
                  ),
                  if (_startDate != null && _endDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Duración: ${_endDate!.difference(_startDate!).inDays + 1} días (máximo 28 días)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _endDate!.difference(_startDate!).inDays + 1 > 28
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ResourceFormField(
                    labelText: 'Criterios de Aceptación',
                    onChanged: (criteria) {
                      setState(() {
                        _acceptanceCriteria = criteria;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ResourceFormField(
                    labelText: 'Recursos Disponibles',
                    onChanged: (resources) {
                      setState(() {
                        _resourcesAvailable = resources;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ResourceFormField(
                    labelText: 'Recursos Necesarios',
                    onChanged: (resources) {
                      setState(() {
                        _resourcesNeeded = resources;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    text: isLoading ? 'Creando...' : 'Crear Sprint',
                    onTap: isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
