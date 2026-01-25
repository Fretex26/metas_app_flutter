import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_milestone.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_milestone.states.dart';
import 'package:metas_app/features/projects/presentation/utils/validators.dart';

/// Página para editar un milestone existente.
/// 
/// Muestra un formulario prellenado con los datos actuales del milestone.
/// Solo permite editar: name y description.
class EditMilestonePage extends StatefulWidget {
  /// Proyecto al que pertenece el milestone
  final String projectId;
  
  /// Milestone a editar
  final Milestone milestone;

  const EditMilestonePage({
    super.key,
    required this.projectId,
    required this.milestone,
  });

  @override
  State<EditMilestonePage> createState() => _EditMilestonePageState();
}

class _EditMilestonePageState extends State<EditMilestonePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.milestone.name);
    _descriptionController = TextEditingController(text: widget.milestone.description ?? '');
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

    final dto = UpdateMilestoneDto(
      name: _nameController.text != widget.milestone.name ? _nameController.text : null,
      description: _descriptionController.text != (widget.milestone.description ?? '')
          ? _descriptionController.text
          : null,
    );

    // Filtrar campos nulos
    final updateData = dto.toJson()..removeWhere((key, value) => value == null);

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<EditMilestoneCubit>().updateMilestone(
      widget.projectId,
      widget.milestone.id,
      dto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Milestone'),
      ),
      body: BlocConsumer<EditMilestoneCubit, EditMilestoneState>(
        listener: (context, state) {
          if (state is EditMilestoneSuccess) {
            Navigator.pop(context, state.milestone);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Milestone actualizado exitosamente')),
            );
          } else if (state is EditMilestoneError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EditMilestoneLoading;

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
