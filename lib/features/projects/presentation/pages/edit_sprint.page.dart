import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_sprint.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_sprint.states.dart';

/// Página para editar un sprint existente.
/// 
/// Muestra un formulario prellenado con los datos actuales del sprint.
/// Permite editar todos los campos del sprint.
class EditSprintPage extends StatefulWidget {
  /// Milestone al que pertenece el sprint
  final String milestoneId;

  /// Sprint a editar
  final Sprint sprint;

  const EditSprintPage({
    super.key,
    required this.milestoneId,
    required this.sprint,
  });

  @override
  State<EditSprintPage> createState() => _EditSprintPageState();
}

class _EditSprintPageState extends State<EditSprintPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _acceptanceCriteria;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sprint.name);
    _descriptionController = TextEditingController(text: widget.sprint.description ?? '');
    _startDate = widget.sprint.startDate;
    _endDate = widget.sprint.endDate;
    _acceptanceCriteria = widget.sprint.acceptanceCriteria;
    _resourcesAvailable = widget.sprint.resourcesAvailable;
    _resourcesNeeded = widget.sprint.resourcesNeeded;
  }

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

    final dto = UpdateSprintDto(
      name: _nameController.text != widget.sprint.name ? _nameController.text : null,
      description: _descriptionController.text != (widget.sprint.description ?? '')
          ? _descriptionController.text
          : null,
      startDate: _startDate != widget.sprint.startDate
          ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
          : null,
      endDate: _endDate != widget.sprint.endDate
          ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
          : null,
      acceptanceCriteria: _acceptanceCriteria != widget.sprint.acceptanceCriteria
          ? _acceptanceCriteria
          : null,
      resourcesAvailable: _resourcesAvailable != widget.sprint.resourcesAvailable
          ? _resourcesAvailable
          : null,
      resourcesNeeded:
          _resourcesNeeded != widget.sprint.resourcesNeeded ? _resourcesNeeded : null,
    );

    // Filtrar campos nulos
    final updateData = dto.toJson()..removeWhere((key, value) => value == null);

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<EditSprintCubit>().updateSprint(widget.milestoneId, widget.sprint.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Sprint'),
      ),
      body: BlocConsumer<EditSprintCubit, EditSprintState>(
        listener: (context, state) {
          if (state is EditSprintSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sprint actualizado exitosamente')),
            );
          } else if (state is EditSprintError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EditSprintLoading;

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
                    text: isLoading ? 'Guardando...' : 'Guardar Cambios',
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
