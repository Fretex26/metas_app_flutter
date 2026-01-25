import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_milestone.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_milestone.states.dart';

/// Página para crear un nuevo milestone dentro de un proyecto.
/// 
/// Muestra un formulario con:
/// - Nombre del milestone (requerido)
/// - Descripción (opcional)
/// - Opción para incluir recompensa (opcional, a diferencia de proyectos)
/// 
/// Valida los datos antes de enviar. Al crear exitosamente, navega de vuelta
/// y actualiza la lista de milestones.
class CreateMilestonePage extends StatefulWidget {
  /// Identificador único del proyecto al que pertenecerá el milestone
  final String projectId;

  /// Constructor de la página de creación de milestone
  const CreateMilestonePage({super.key, required this.projectId});

  @override
  State<CreateMilestonePage> createState() => _CreateMilestonePageState();
}

class _CreateMilestonePageState extends State<CreateMilestonePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardNameController = TextEditingController();
  final _rewardDescriptionController = TextEditingController();
  final _rewardClaimInstructionsController = TextEditingController();
  final _rewardClaimLinkController = TextEditingController();

  bool _hasReward = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rewardNameController.dispose();
    _rewardDescriptionController.dispose();
    _rewardClaimInstructionsController.dispose();
    _rewardClaimLinkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    RewardDto? reward;
    if (_hasReward) {
      if (_rewardNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre de la recompensa es obligatorio si se incluye')),
        );
        return;
      }
      reward = RewardDto(
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
      );
    }

    final dto = CreateMilestoneDto(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      reward: reward,
    );

    context.read<CreateMilestoneCubit>().createMilestone(widget.projectId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Milestone'),
      ),
      body: BlocConsumer<CreateMilestoneCubit, CreateMilestoneState>(
        listener: (context, state) {
          if (state is CreateMilestoneSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Milestone creado exitosamente')),
            );
          } else if (state is CreateMilestoneError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateMilestoneLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _nameController,
                    hintText: 'Nombre del milestone *',
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
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    title: const Text('Incluir recompensa (opcional)'),
                    value: _hasReward,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _hasReward = value ?? false;
                            });
                          },
                  ),
                  if (_hasReward) ...[
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _rewardNameController,
                      hintText: 'Nombre de la recompensa',
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
                  ],
                  const SizedBox(height: 32),
                  MyButton(
                    text: isLoading ? 'Creando...' : 'Crear Milestone',
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
