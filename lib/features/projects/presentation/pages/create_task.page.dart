import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_sprints.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/sprint.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.states.dart';

/// Página para crear una nueva task dentro de un milestone.
/// 
/// Muestra un formulario con:
/// - Nombre de la task (requerido)
/// - Descripción (opcional)
/// - Fechas de inicio y fin (requeridas, la de fin debe ser posterior a la de inicio)
/// - Selector de sprint (opcional)
/// - Puntos de incentivo (opcional)
/// - Formularios dinámicos para recursos disponibles y necesarios
/// 
/// Valida los datos antes de enviar. Al crear exitosamente, navega de vuelta
/// y actualiza la lista de tasks.
class CreateTaskPage extends StatefulWidget {
  /// Identificador único del milestone al que pertenecerá la task
  final String milestoneId;

  /// Identificador único del sprint al que se asignará la task (opcional)
  /// Si se proporciona, se pre-seleccionará en el dropdown
  final String? initialSprintId;

  /// Constructor de la página de creación de task
  const CreateTaskPage({
    super.key,
    required this.milestoneId,
    this.initialSprintId,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _incentivePointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        // Si hay un sprint inicial y existe en la lista, seleccionarlo
        if (widget.initialSprintId != null &&
            sprints.any((s) => s.id == widget.initialSprintId)) {
          _selectedSprintId = widget.initialSprintId;
          final selectedSprint = sprints.firstWhere((s) => s.id == widget.initialSprintId);
          // Pre-llenar las fechas con el rango del sprint
          _startDate = selectedSprint.startDate;
          _endDate = selectedSprint.endDate;
        }
      });
    } catch (e) {
      setState(() {
        _loadingSprints = false;
      });
      // No mostrar error, simplemente no mostrar sprints
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedSprintId;
  List<Sprint> _sprints = [];
  bool _loadingSprints = false;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

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

    final dto = CreateTaskDto(
      milestoneId: widget.milestoneId,
      sprintId: _selectedSprintId,
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
                  if (_loadingSprints)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_sprints.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedSprintId,
                      decoration: InputDecoration(
                        labelText: 'Sprint (opcional)',
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
                                // Si se selecciona un sprint, ajustar las fechas sugeridas
                                if (value != null) {
                                  final selectedSprint =
                                      _sprints.firstWhere((s) => s.id == value);
                                  if (_startDate == null ||
                                      _startDate!.isBefore(selectedSprint.startDate)) {
                                    _startDate = selectedSprint.startDate;
                                  }
                                  if (_endDate == null ||
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
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
