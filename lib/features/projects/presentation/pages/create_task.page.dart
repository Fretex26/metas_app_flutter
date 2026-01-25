import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.states.dart';

/// Página para crear una nueva task dentro de un milestone.
/// 
/// Muestra un formulario con:
/// - Nombre de la task (requerido)
/// - Descripción (opcional)
/// - Fechas de inicio y fin (requeridas, la de fin debe ser posterior a la de inicio)
/// - Puntos de incentivo (opcional)
/// - Formularios dinámicos para recursos disponibles y necesarios
/// 
/// Valida los datos antes de enviar. Al crear exitosamente, navega de vuelta
/// y actualiza la lista de tasks.
class CreateTaskPage extends StatefulWidget {
  /// Identificador único del milestone al que pertenecerá la task
  final String milestoneId;

  /// Constructor de la página de creación de task
  const CreateTaskPage({super.key, required this.milestoneId});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _incentivePointsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _incentivePointsController.dispose();
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

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio')),
      );
      return;
    }

    final dto = CreateTaskDto(
      milestoneId: widget.milestoneId,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      startDate:
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
      endDate:
          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
      resourcesAvailable: _resourcesAvailable,
      resourcesNeeded: _resourcesNeeded,
      incentivePoints: _incentivePointsController.text.isEmpty
          ? null
          : int.tryParse(_incentivePointsController.text),
    );

    context.read<CreateTaskCubit>().createTask(widget.milestoneId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Task'),
      ),
      body: BlocConsumer<CreateTaskCubit, CreateTaskState>(
        listener: (context, state) {
          if (state is CreateTaskSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task creada exitosamente')),
            );
          } else if (state is CreateTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateTaskLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _nameController,
                    hintText: 'Nombre de la task *',
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
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: _incentivePointsController,
                    hintText: 'Puntos de incentivo',
                    obscureText: false,
                    enabled: !isLoading,
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
                    text: isLoading ? 'Creando...' : 'Crear Task',
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
