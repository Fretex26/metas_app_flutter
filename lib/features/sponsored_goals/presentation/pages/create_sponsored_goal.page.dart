import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/create_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_categories.use_case.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/create_sponsored_goal.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/create_sponsored_goal.states.dart';

/// Página para crear un nuevo Sponsored Goal (solo sponsors).
/// 
/// Muestra un formulario completo con todos los campos necesarios:
/// - Selección del proyecto base
/// - Nombre y descripción del objetivo
/// - Fechas de inicio y fin
/// - Número máximo de usuarios
/// - Recompensa opcional
/// 
/// Valida los datos antes de enviar y muestra mensajes de error apropiados.
class CreateSponsoredGoalPage extends StatefulWidget {
  const CreateSponsoredGoalPage({super.key});

  @override
  State<CreateSponsoredGoalPage> createState() =>
      _CreateSponsoredGoalPageState();
}

class _CreateSponsoredGoalPageState extends State<CreateSponsoredGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxUsersController = TextEditingController(text: '100');

  Project? _selectedProject;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Project> _projects = [];
  List<Category> _categories = [];
  List<String> _selectedCategoryIds = [];
  bool _loadingProjects = true;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadCategories();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await context.read<GetUserProjectsUseCase>()();
      setState(() {
        _projects = projects;
        _loadingProjects = false;
      });
    } catch (e) {
      setState(() {
        _loadingProjects = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar proyectos: $e')),
        );
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await context.read<GetCategoriesUseCase>()();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
      // No mostrar error si falla, las categorías son opcionales
      // Si el endpoint no existe (404), simplemente no cargar categorías
      if (mounted && !e.toString().contains('404')) {
        // Solo mostrar error si no es 404 (endpoint no existe)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron cargar las categorías. Puedes continuar sin seleccionarlas.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _maxUsersController.text = '100';
    setState(() {
      _selectedProject = null;
      _startDate = null;
      _endDate = null;
      _selectedCategoryIds = [];
    });
    _formKey.currentState?.reset();
  }

  void _submit(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un proyecto')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar las fechas')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio')),
      );
      return;
    }

    final maxUsers = int.tryParse(_maxUsersController.text);
    if (maxUsers == null || maxUsers < 1) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('El número máximo de usuarios debe ser al menos 1')),
      );
      return;
    }

    final dto = CreateSponsoredGoalDto(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      projectId: _selectedProject!.id,
      categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
      startDate: '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
      endDate: '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
      maxUsers: maxUsers,
    );

    blocContext.read<CreateSponsoredGoalCubit>().createSponsoredGoal(dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateSponsoredGoalCubit(
        createSponsoredGoalUseCase: context.read<CreateSponsoredGoalUseCase>(),
      ),
      child: BlocListener<CreateSponsoredGoalCubit, CreateSponsoredGoalState>(
        listener: (context, state) {
          if (state is CreateSponsoredGoalCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Objetivo patrocinado creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context, true);
            } else {
              context.read<CreateSponsoredGoalCubit>().reset();
              _resetForm();
            }
          }
          if (state is CreateSponsoredGoalError) {
            final guidance = state.message.toLowerCase().contains('milestone') ||
                    state.message.toLowerCase().contains('task')
                ? '\n\nRevisa que el proyecto tenga al menos una milestone y cada una al menos una task.'
                : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.message}$guidance'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Crear Objetivo Patrocinado'),
          ),
          body: _loadingProjects || _loadingCategories
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selección de proyecto
                        DropdownButtonFormField<Project>(
                          initialValue: _selectedProject,
                          decoration: const InputDecoration(
                            labelText: 'Proyecto base *',
                            border: OutlineInputBorder(),
                          ),
                          items: _projects.map((project) {
                            return DropdownMenuItem(
                              value: project,
                              child: Text(project.name),
                            );
                          }).toList(),
                          onChanged: (project) {
                            setState(() {
                              _selectedProject = project;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Debes seleccionar un proyecto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El proyecto debe tener al menos una milestone y cada milestone al menos una task. No se requieren sprints.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nombre
                        MyTextField(
                          controller: _nameController,
                          hintText: 'Nombre del objetivo *',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (value.length > 255) {
                              return 'El nombre no puede exceder 255 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Descripción
                        MyTextFieldMultiline(
                          controller: _descriptionController,
                          hintText: 'Descripción',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        // Fecha de inicio
                        MyDatePicker(
                          labelText: 'Fecha de inicio *',
                          selectedDate: _startDate,
                          onDateSelected: (date) {
                            setState(() {
                              _startDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Fecha de fin
                        MyDatePicker(
                          labelText: 'Fecha de fin *',
                          selectedDate: _endDate,
                          onDateSelected: (date) {
                            setState(() {
                              _endDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Selección de categorías
                        if (_categories.isNotEmpty) ...[
                          Text(
                            'Categorías (opcional)',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _categories.map((category) {
                                final isSelected =
                                    _selectedCategoryIds.contains(category.id);
                                return FilterChip(
                                  label: Text(category.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategoryIds.add(category.id);
                                      } else {
                                        _selectedCategoryIds.remove(category.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Máximo de usuarios
                        Text(
                          'Máximo de usuarios (límite de participantes) *',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        MyTextField(
                          controller: _maxUsersController,
                          hintText: 'Ej: 100',
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El número máximo de usuarios es obligatorio';
                            }
                            final maxUsers = int.tryParse(value);
                            if (maxUsers == null || maxUsers < 1) {
                              return 'Debe ser un número mayor a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Botón de crear
                        BlocBuilder<CreateSponsoredGoalCubit,
                            CreateSponsoredGoalState>(
                          builder: (context, state) {
                            final isCreating =
                                state is CreateSponsoredGoalCreating;
                            return FilledButton(
                              onPressed: isCreating ? null : () => _submit(context),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: isCreating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Crear Objetivo Patrocinado',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
