import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/domain/entities/task.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_task.states.dart';
import 'package:metas_app/features/projects/presentation/utils/validators.dart';

/// Página para editar una task existente.
class EditTaskPage extends StatefulWidget {
  final String milestoneId;
  final Task task;

  const EditTaskPage({
    super.key,
    required this.milestoneId,
    required this.task,
  });

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _incentivePointsController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _incentivePointsController = TextEditingController(
      text: widget.task.incentivePoints?.toString() ?? '',
    );
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
  }

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

    final dateValidation = TaskValidators.validateDates(_startDate, _endDate);
    if (dateValidation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateValidation)),
      );
      return;
    }

    final dto = UpdateTaskDto(
      name: _nameController.text != widget.task.name ? _nameController.text : null,
      description: _descriptionController.text != (widget.task.description ?? '')
          ? _descriptionController.text
          : null,
      startDate: _startDate != widget.task.startDate
          ? _startDate?.toIso8601String().split('T')[0]
          : null,
      endDate: _endDate != widget.task.endDate
          ? _endDate?.toIso8601String().split('T')[0]
          : null,
      incentivePoints: _incentivePointsController.text.isNotEmpty
          ? int.tryParse(_incentivePointsController.text)
          : null,
    );

    final updateData = dto.toJson()..removeWhere((key, value) => value == null);

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<EditTaskCubit>().updateTask(widget.milestoneId, widget.task.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Task'),
      ),
      body: BlocConsumer<EditTaskCubit, EditTaskState>(
        listener: (context, state) {
          if (state is EditTaskSuccess) {
            Navigator.pop(context, state.task);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task actualizada exitosamente')),
            );
          } else if (state is EditTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EditTaskLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Nombre *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: ProjectValidators.validateName,
                ),
                const SizedBox(height: 16),
                MyTextFieldMultiline(
                  controller: _descriptionController,
                  hintText: 'Descripción',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                MyDatePicker(
                  labelText: 'Fecha de Inicio',
                  selectedDate: _startDate,
                  onDateSelected: (date) {
                    setState(() {
                      _startDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                MyDatePicker(
                  labelText: 'Fecha de Fin',
                  selectedDate: _endDate,
                  firstDate: _startDate,
                  requireFirstDate: true,
                  missingFirstDateMessage: 'Selecciona primero la fecha de inicio',
                  onDateSelected: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _incentivePointsController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Puntos de Incentivo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: TaskValidators.validateIncentivePoints,
                ),
                const SizedBox(height: 24),
                MyButton(
                  text: isLoading ? 'Guardando...' : 'Guardar Cambios',
                  onTap: isLoading ? null : _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
