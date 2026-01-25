import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_project.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_project.states.dart';
import 'package:metas_app/features/projects/presentation/utils/validators.dart';

/// Página para editar un proyecto existente.
/// 
/// Muestra un formulario prellenado con los datos actuales del proyecto.
/// Solo permite editar: name, description, purpose, budget, finalDate,
/// resourcesAvailable y resourcesNeeded.
/// 
/// Al guardar exitosamente, navega de vuelta con el proyecto actualizado.
class EditProjectPage extends StatefulWidget {
  /// Proyecto a editar
  final Project project;

  /// Constructor de la página de edición de proyecto
  const EditProjectPage({super.key, required this.project});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _purposeController;
  late TextEditingController _budgetController;
  DateTime? _finalDate;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

  /// Convierte un Map<String, dynamic> a List<ResourceItem>
  List<ResourceItem> _mapToResourceItems(Map<String, dynamic>? map) {
    if (map == null) return [];
    return map.entries.map((entry) => ResourceItem(
      name: entry.key,
      description: entry.value.toString(),
    )).toList();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _purposeController = TextEditingController(text: widget.project.purpose ?? '');
    _budgetController = TextEditingController(
      text: widget.project.budget?.toString() ?? '',
    );
    _finalDate = widget.project.finalDate;
    _resourcesAvailable = widget.project.resourcesAvailable;
    _resourcesNeeded = widget.project.resourcesNeeded;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _purposeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = UpdateProjectDto(
      name: _nameController.text != widget.project.name ? _nameController.text : null,
      description: _descriptionController.text != (widget.project.description ?? '')
          ? _descriptionController.text
          : null,
      purpose: _purposeController.text != (widget.project.purpose ?? '')
          ? _purposeController.text
          : null,
      budget: _budgetController.text.isNotEmpty
          ? double.tryParse(_budgetController.text)
          : null,
      finalDate: _finalDate != widget.project.finalDate
          ? _finalDate?.toIso8601String().split('T')[0]
          : null,
      resourcesAvailable: _resourcesAvailable,
      resourcesNeeded: _resourcesNeeded,
    );

    // Filtrar campos nulos
    final updateData = dto.toJson()..removeWhere((key, value) => value == null);

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<EditProjectCubit>().updateProject(widget.project.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Proyecto'),
      ),
      body: BlocConsumer<EditProjectCubit, EditProjectState>(
        listener: (context, state) {
          if (state is EditProjectSuccess) {
            Navigator.pop(context, state.project);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proyecto actualizado exitosamente')),
            );
          } else if (state is EditProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EditProjectLoading;

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
                MyTextFieldMultiline(
                  controller: _purposeController,
                  hintText: 'Propósito',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Presupuesto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: ProjectValidators.validateBudget,
                ),
                const SizedBox(height: 16),
                MyDatePicker(
                  labelText: 'Fecha Final',
                  selectedDate: _finalDate,
                  onDateSelected: (date) {
                    setState(() {
                      _finalDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ResourceFormField(
                  labelText: 'Recursos Disponibles',
                  initialResources: _mapToResourceItems(_resourcesAvailable),
                  onChanged: (resources) {
                    setState(() {
                      _resourcesAvailable = resources;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ResourceFormField(
                  labelText: 'Recursos Necesarios',
                  initialResources: _mapToResourceItems(_resourcesNeeded),
                  onChanged: (resources) {
                    setState(() {
                      _resourcesNeeded = resources;
                    });
                  },
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
