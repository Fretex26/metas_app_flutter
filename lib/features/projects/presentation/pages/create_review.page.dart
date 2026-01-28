import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_review.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_review.states.dart';

/// Página para crear una nueva review de un sprint.
/// 
/// Muestra un formulario con:
/// - Puntos extra (opcional, por defecto: 0)
/// - Resumen de la revisión (obligatorio)
/// 
/// El porcentaje de progreso se calcula automáticamente en el backend.
/// Solo se puede crear una review por sprint.
class CreateReviewPage extends StatefulWidget {
  /// Identificador único del sprint para el cual se crea la review
  final String sprintId;

  /// Constructor de la página de creación de review
  const CreateReviewPage({
    super.key,
    required this.sprintId,
  });

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _extraPointsController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _extraPointsController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final extraPoints = _extraPointsController.text.isEmpty
        ? null
        : int.tryParse(_extraPointsController.text);

    if (_extraPointsController.text.isNotEmpty && (extraPoints == null || extraPoints < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los puntos extra deben ser un número mayor o igual a 0')),
      );
      return;
    }

    final dto = CreateReviewDto(
      extraPoints: extraPoints,
      summary: _summaryController.text.trim(),
    );

    context.read<CreateReviewCubit>().createReview(widget.sprintId, dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateReviewCubit, CreateReviewState>(
      listener: (context, state) {
        if (state is CreateReviewSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review creada exitosamente')),
          );
        } else if (state is CreateReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Review'),
        ),
        body: BlocBuilder<CreateReviewCubit, CreateReviewState>(
          builder: (context, state) {
            final isLoading = state is CreateReviewLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Crea una review para este sprint donde expreses los resultados del sprint desde el punto de vista del objetivo del proyecto. El porcentaje de progreso se calculará automáticamente basado en las tareas completadas del proyecto.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextField(
                      controller: _extraPointsController,
                      hintText: 'Puntos extra (opcional)',
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final points = int.tryParse(value);
                          if (points == null || points < 0) {
                            return 'Debe ser un número mayor o igual a 0';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldMultiline(
                      controller: _summaryController,
                      hintText: 'Resume los resultados del sprint. *',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El resumen es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    MyButton(
                      text: isLoading ? 'Creando...' : 'Crear Review',
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
