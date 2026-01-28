import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/domain/entities/difficulty.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_daily_entry.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_daily_entry.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_daily_entry.states.dart';

/// Página para crear una nueva entrada diaria.
/// 
/// Muestra un formulario con:
/// - Notas sobre lo realizado ayer (requerido)
/// - Notas sobre lo planeado para hoy (requerido)
/// - Nivel de dificultad (requerido)
/// 
/// El campo energyChange siempre se envía como "increased" ya que
/// cada vez que el usuario completa un daily, como recompensa se incrementa la energía.
/// 
/// **Importante**: El sprintId es requerido. Solo se permite una entrada diaria por día por usuario.
/// Puede estar asociada opcionalmente a una tarea específica.
class CreateDailyEntryPage extends StatefulWidget {
  /// Identificador de la tarea relacionada (opcional)
  final String? taskId;

  /// Identificador del sprint relacionado (requerido)
  final String sprintId;

  /// Constructor de la página de creación de entrada diaria
  /// 
  /// [sprintId] - Requerido: Identificador del sprint al que pertenece la entrada diaria
  /// [taskId] - Opcional: Identificador de la tarea relacionada
  const CreateDailyEntryPage({
    super.key,
    required this.sprintId,
    this.taskId,
  });

  @override
  State<CreateDailyEntryPage> createState() => _CreateDailyEntryPageState();
}

class _CreateDailyEntryPageState extends State<CreateDailyEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesYesterdayController = TextEditingController();
  final _notesTodayController = TextEditingController();
  Difficulty _selectedDifficulty = Difficulty.medium;

  @override
  void dispose() {
    _notesYesterdayController.dispose();
    _notesTodayController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = CreateDailyEntryDto(
      taskId: widget.taskId,
      sprintId: widget.sprintId,
      notesYesterday: _notesYesterdayController.text.trim(),
      notesToday: _notesTodayController.text.trim(),
      difficulty: _selectedDifficulty,
    );

    context.read<CreateDailyEntryCubit>().createDailyEntry(dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateDailyEntryCubit, CreateDailyEntryState>(
      listener: (context, state) {
        if (state is CreateDailyEntrySuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada diaria creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CreateDailyEntryError) {
          // Mostrar mensaje de error más amigable, especialmente para el error 409
          final errorMessage = state.message.contains('Ya existe una entrada diaria')
              ? state.message
              : 'Error: ${state.message}';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: state.message.contains('Ya existe una entrada diaria')
                  ? Colors.orange
                  : Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Entrada Diaria'),
        ),
        body: BlocBuilder<CreateDailyEntryCubit, CreateDailyEntryState>(
          builder: (context, state) {
            final isLoading = state is CreateDailyEntryLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Registra tu progreso diario. Documenta lo que hiciste ayer y lo que planeas hacer hoy. Como recompensa por completar tu daily, tu energía se incrementará automáticamente.\n\nSolo se permite una entrada diaria por día.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextFieldMultiline(
                      controller: _notesYesterdayController,
                      hintText: 'Notas de Ayer *',
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
                      controller: _notesTodayController,
                      hintText: '¿Qué planeas para Hoy? *',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Difficulty>(
                      initialValue: _selectedDifficulty,
                      decoration: InputDecoration(
                        labelText: 'Dificultad del trabajo de ayer *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      items: Difficulty.values.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty.displayName),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDifficulty = value;
                                });
                              }
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un nivel de dificultad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    MyButton(
                      text: isLoading ? 'Creando...' : 'Crear Entrada Diaria',
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
