import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_sprints.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/sprint.dart';
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
  String? _selectedSprintId;
  List<Sprint> _sprints = [];
  bool _loadingSprints = false;
  bool _sprintChanged = false;

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
    _selectedSprintId = widget.task.sprintId;
    _loadSprints();
  }

  Future<void> _loadSprints() async {
    setState(() {
      _loadingSprints = true;
    });
    try {
      final sprints = await context.read<GetMilestoneSprintsUseCase>()(widget.milestoneId);
      setState(() {
        _sprints = sprints;
        _loadingSprints = false;
      });
    } catch (e) {
      setState(() {
        _loadingSprints = false;
      });
      // No mostrar error, simplemente no mostrar sprints
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

    // Validar que si se seleccionó un sprint, las fechas estén dentro del rango del sprint
    if (_selectedSprintId != null) {
      final selectedSprint = _sprints.firstWhere((s) => s.id == _selectedSprintId);
      if (_startDate!.isBefore(selectedSprint.startDate) ||
          _endDate!.isAfter(selectedSprint.endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Las fechas de la task deben estar dentro del rango del sprint seleccionado',
            ),
          ),
        );
        return;
      }
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
      sprintId: _sprintChanged ? _selectedSprintId : null,
      incentivePoints: _incentivePointsController.text.isNotEmpty
          ? int.tryParse(_incentivePointsController.text)
          : null,
    );

    // Si el sprint cambió, marcar que debe incluirse en el JSON (incluso si es null para desasignar)
    if (_sprintChanged) {
      dto.markSprintIdForUpdate();
    }

    final updateData = dto.toJson();
    updateData.removeWhere((key, value) => value == null && key != 'sprintId');

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
                if (_loadingSprints)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_sprints.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSprintId,
                    decoration: InputDecoration(
                      labelText: 'Sprint',
                      hintText: 'Selecciona un sprint',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Theme.of(context).colorScheme.secondary,
                      filled: true,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Sin sprint'),
                      ),
                      ..._sprints.map((sprint) {
                        return DropdownMenuItem<String>(
                          value: sprint.id,
                          child: Text(
                            sprint.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedSprintId = value;
                              _sprintChanged = true;
                              // Si se selecciona un sprint, ajustar las fechas si están fuera del rango
                              if (value != null) {
                                final selectedSprint =
                                    _sprints.firstWhere((s) => s.id == value);
                                if (_startDate != null &&
                                    _startDate!.isBefore(selectedSprint.startDate)) {
                                  _startDate = selectedSprint.startDate;
                                }
                                if (_endDate != null &&
                                    _endDate!.isAfter(selectedSprint.endDate)) {
                                  _endDate = selectedSprint.endDate;
                                }
                              }
                            });
                          },
                  ),
                  if (_selectedSprintId != null) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final selectedSprint =
                            _sprints.firstWhere((s) => s.id == _selectedSprintId);
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rango del sprint: ${_formatDate(selectedSprint.startDate)} - ${_formatDate(selectedSprint.endDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
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
