import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.states.dart';

/// Página para editar un checklist item existente.
/// 
/// Muestra un formulario prellenado con los datos actuales del checklist item.
/// Permite editar: description, isRequired e isChecked.
class EditChecklistItemPage extends StatefulWidget {
  /// Identificador único de la task a la que pertenece el checklist item
  final String taskId;
  
  /// Checklist item a editar
  final ChecklistItem item;

  const EditChecklistItemPage({
    super.key,
    required this.taskId,
    required this.item,
  });

  @override
  State<EditChecklistItemPage> createState() => _EditChecklistItemPageState();
}

class _EditChecklistItemPageState extends State<EditChecklistItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late bool _isRequired;
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _isRequired = widget.item.isRequired;
    _isChecked = widget.item.isChecked;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción es requerida')),
      );
      return;
    }

    final dto = UpdateChecklistItemDto(
      description: _descriptionController.text != widget.item.description
          ? _descriptionController.text
          : null,
      isRequired: _isRequired != widget.item.isRequired ? _isRequired : null,
      isChecked: _isChecked != widget.item.isChecked ? _isChecked : null,
    );

    // Filtrar campos nulos
    final updateData = dto.toJson()..removeWhere((key, value) => value == null);

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<ChecklistCubit>().updateChecklistItem(widget.taskId, widget.item.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Checklist Item'),
      ),
      body: BlocConsumer<ChecklistCubit, ChecklistState>(
        listener: (context, state) {
          if (state is ChecklistItemUpdated) {
            Navigator.pop(context, state.item);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checklist item actualizado exitosamente')),
            );
          } else if (state is ChecklistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ChecklistItemUpdating;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                MyTextField(
                  controller: _descriptionController,
                  hintText: 'Descripción *',
                  obscureText: false,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Requerido'),
                  subtitle: const Text('Este item debe completarse para finalizar la task'),
                  value: _isRequired,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _isRequired = value ?? false;
                          });
                        },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Completado'),
                  subtitle: const Text('Marca este item como completado'),
                  value: _isChecked,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _isChecked = value ?? false;
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
