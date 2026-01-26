import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_retrospective.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_retrospective.states.dart';

/// Página para crear una nueva retrospectiva de un sprint.
/// 
/// Muestra un formulario con:
/// - Lo que salió bien (requerido)
/// - Lo que salió mal (requerido)
/// - Mejoras propuestas (opcional)
/// - Checkbox para marcar como pública o privada
/// 
/// Solo se puede crear una retrospectiva por sprint.
class CreateRetrospectivePage extends StatefulWidget {
  /// Identificador único del sprint para el cual se crea la retrospectiva
  final String sprintId;

  /// Constructor de la página de creación de retrospectiva
  const CreateRetrospectivePage({
    super.key,
    required this.sprintId,
  });

  @override
  State<CreateRetrospectivePage> createState() => _CreateRetrospectivePageState();
}

class _CreateRetrospectivePageState extends State<CreateRetrospectivePage> {
  final _formKey = GlobalKey<FormState>();
  final _whatWentWellController = TextEditingController();
  final _whatWentWrongController = TextEditingController();
  final _improvementsController = TextEditingController();
  bool _isPublic = false;

  @override
  void dispose() {
    _whatWentWellController.dispose();
    _whatWentWrongController.dispose();
    _improvementsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = CreateRetrospectiveDto(
      whatWentWell: _whatWentWellController.text.trim(),
      whatWentWrong: _whatWentWrongController.text.trim(),
      improvements: _improvementsController.text.trim().isEmpty
          ? null
          : _improvementsController.text.trim(),
      isPublic: _isPublic,
    );

    context.read<CreateRetrospectiveCubit>().createRetrospective(widget.sprintId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateRetrospectiveCubit, CreateRetrospectiveState>(
      listener: (context, state) {
        if (state is CreateRetrospectiveSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Retrospectiva creada exitosamente')),
          );
        } else if (state is CreateRetrospectiveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Retrospectiva'),
        ),
        body: BlocBuilder<CreateRetrospectiveCubit, CreateRetrospectiveState>(
          builder: (context, state) {
            final isLoading = state is CreateRetrospectiveLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Crea una retrospectiva para este sprint. Desde el punto de vista de tu trabajo y esfuerzos, analiza lo que salió bien, lo que salió mal y propón mejoras para futuros sprints.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextFieldMultiline(
                      controller: _whatWentWellController,
                      hintText: 'Lo que salió bien *',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldMultiline(
                      controller: _whatWentWrongController,
                      hintText: 'Lo que salió mal *',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldMultiline(
                      controller: _improvementsController,
                      hintText: 'Mejoras propuestas (opcional)',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: CheckboxListTile(
                        title: const Text('Hacer retrospectiva pública'),
                        subtitle: const Text(
                          'Las retrospectivas públicas pueden ser vistas por todos los usuarios',
                        ),
                        value: _isPublic,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _isPublic = value ?? false;
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 32),
                    MyButton(
                      text: isLoading ? 'Creando...' : 'Crear Retrospectiva',
                      onTap: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
