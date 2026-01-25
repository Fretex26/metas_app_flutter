import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/components/resource_form_field.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_project.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_project.states.dart';

/// Página para crear un nuevo proyecto.
/// 
/// Muestra un formulario completo con todos los campos necesarios:
/// - Información básica del proyecto (nombre, descripción, propósito, presupuesto, fecha límite)
/// - Formularios dinámicos para recursos disponibles y necesarios
/// - Formulario de recompensa (obligatoria)
/// 
/// Valida los datos antes de enviar y muestra mensajes de error apropiados.
/// Al crear exitosamente, navega de vuelta a la lista de proyectos.
class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purposeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _rewardNameController = TextEditingController();
  final _rewardDescriptionController = TextEditingController();
  final _rewardClaimInstructionsController = TextEditingController();
  final _rewardClaimLinkController = TextEditingController();

  DateTime? _finalDate;
  Map<String, dynamic>? _resourcesAvailable;
  Map<String, dynamic>? _resourcesNeeded;

  /// Limpia los recursos al destruir el widget
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _purposeController.dispose();
    _budgetController.dispose();
    _rewardNameController.dispose();
    _rewardDescriptionController.dispose();
    _rewardClaimInstructionsController.dispose();
    _rewardClaimLinkController.dispose();
    super.dispose();
  }

  /// Valida y envía el formulario para crear el proyecto.
  /// 
  /// Valida que:
  /// - El nombre del proyecto esté presente
  /// - El nombre de la recompensa esté presente (obligatorio)
  /// 
  /// Si la validación pasa, crea el proyecto usando el cubit.
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rewardNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la recompensa es obligatorio')),
      );
      return;
    }

    final dto = CreateProjectDto(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      purpose: _purposeController.text.isEmpty ? null : _purposeController.text,
      budget: _budgetController.text.isEmpty ? null : double.tryParse(_budgetController.text),
      finalDate: _finalDate != null
          ? '${_finalDate!.year}-${_finalDate!.month.toString().padLeft(2, '0')}-${_finalDate!.day.toString().padLeft(2, '0')}'
          : null,
      resourcesAvailable: _resourcesAvailable,
      resourcesNeeded: _resourcesNeeded,
      reward: RewardDto(
        name: _rewardNameController.text,
        description: _rewardDescriptionController.text.isEmpty
            ? null
            : _rewardDescriptionController.text,
        claimInstructions: _rewardClaimInstructionsController.text.isEmpty
            ? null
            : _rewardClaimInstructionsController.text,
        claimLink: _rewardClaimLinkController.text.isEmpty
            ? null
            : _rewardClaimLinkController.text,
      ),
    );

    context.read<CreateProjectCubit>().createProject(dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Proyecto'),
      ),
      body: BlocConsumer<CreateProjectCubit, CreateProjectState>(
        listener: (context, state) {
          if (state is CreateProjectSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proyecto creado exitosamente')),
            );
          } else if (state is CreateProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateProjectLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Proyecto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: _nameController,
                    hintText: 'Nombre del proyecto *',
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
                  MyTextField(
                    controller: _purposeController,
                    hintText: 'Propósito',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: _budgetController,
                    hintText: 'Presupuesto',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyDatePicker(
                    selectedDate: _finalDate,
                    onDateSelected: (date) {
                      setState(() {
                        _finalDate = date;
                      });
                    },
                    labelText: 'Fecha límite',
                    hintText: 'Selecciona una fecha',
                  ),
                  const SizedBox(height: 24),
                  ResourceFormField(
                    labelText: 'Recursos Disponibles',
                    onChanged: (resources) {
                      // Schedule setState to run after the current frame to avoid setState during build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _resourcesAvailable = resources;
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ResourceFormField(
                    labelText: 'Recursos Necesarios',
                    onChanged: (resources) {
                      // Schedule setState to run after the current frame to avoid setState during build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _resourcesNeeded = resources;
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recompensa del Proyecto *',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: _rewardNameController,
                    hintText: 'Nombre de la recompensa *',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyTextFieldMultiline(
                    controller: _rewardDescriptionController,
                    hintText: 'Descripción de la recompensa',
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyTextFieldMultiline(
                    controller: _rewardClaimInstructionsController,
                    hintText: 'Instrucciones para reclamar',
                    maxLines: 2,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: _rewardClaimLinkController,
                    hintText: 'Link para reclamar (URL)',
                    obscureText: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    text: isLoading ? 'Creando...' : 'Crear Proyecto',
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
