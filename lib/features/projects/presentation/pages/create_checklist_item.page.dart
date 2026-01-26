import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.states.dart';

/// Página para crear un nuevo checklist item dentro de una task.
/// 
/// Muestra un formulario simple con:
/// - Descripción del item (requerida)
/// - Checkbox para marcar como requerido (opcional)
/// 
/// Al crear exitosamente, el estado de la task se actualiza automáticamente
/// en el backend según las reglas de dependencias.
class CreateChecklistItemPage extends StatefulWidget {
  /// Identificador único de la task a la que pertenecerá el checklist item
  final String taskId;

  /// Constructor de la página de creación de checklist item
  const CreateChecklistItemPage({super.key, required this.taskId});

  @override
  State<CreateChecklistItemPage> createState() => _CreateChecklistItemPageState();
}

class _CreateChecklistItemPageState extends State<CreateChecklistItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _isRequired = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = CreateChecklistItemDto(
      description: _descriptionController.text,
      isRequired: _isRequired,
    );

    context.read<ChecklistCubit>().createChecklistItem(widget.taskId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Checklist Item'),
      ),
      body: BlocConsumer<ChecklistCubit, ChecklistState>(
        listener: (context, state) {
          if (state is ChecklistItemCreated) {
            // Regresar a la página anterior (TaskDetailPage) en lugar de ir al milestone
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checklist item creado exitosamente')),
            );
          } else if (state is ChecklistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ChecklistLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _descriptionController,
                    hintText: 'Descripción *',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Item requerido'),
                    value: _isRequired,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isRequired = value ?? false;
                            });
                          },
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    text: isLoading ? 'Creando...' : 'Crear Checklist Item',
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
