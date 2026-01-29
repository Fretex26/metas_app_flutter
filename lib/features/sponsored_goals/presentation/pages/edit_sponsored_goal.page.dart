import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_date_picker.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_categories.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/update_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/verification_method.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_sponsored_goal.dto.dart';

/// Formulario para editar un Sponsored Goal (solo sponsor dueño).
class EditSponsoredGoalPage extends StatefulWidget {
  final SponsoredGoal goal;

  const EditSponsoredGoalPage({super.key, required this.goal});

  @override
  State<EditSponsoredGoalPage> createState() => _EditSponsoredGoalPageState();
}

class _EditSponsoredGoalPageState extends State<EditSponsoredGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxUsersController;

  DateTime? _startDate;
  DateTime? _endDate;
  List<Category> _categories = [];
  List<String> _selectedCategoryIds = [];
  VerificationMethod _verificationMethod = VerificationMethod.manual;
  bool _loadingCategories = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _descriptionController = TextEditingController(text: widget.goal.description ?? '');
    _maxUsersController = TextEditingController(text: '${widget.goal.maxUsers}');
    _startDate = widget.goal.startDate;
    _endDate = widget.goal.endDate;
    _verificationMethod = widget.goal.verificationMethod;
    _selectedCategoryIds = widget.goal.categories?.map((c) => c.id).toList() ?? [];
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await context.read<GetCategoriesUseCase>()();
      setState(() {
        _categories = list;
        _loadingCategories = false;
      });
    } catch (_) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar las fechas')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio')),
      );
      return;
    }
    final maxUsers = int.tryParse(_maxUsersController.text);
    if (maxUsers == null || maxUsers < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El número máximo de usuarios debe ser al menos 1')),
      );
      return;
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final updateUseCase = context.read<UpdateSponsoredGoalUseCase>();
    try {
      final dto = UpdateSponsoredGoalDto(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        categoryIds: _selectedCategoryIds.isEmpty ? [] : _selectedCategoryIds,
        startDate: '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
        endDate: '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
        verificationMethod: _verificationMethod,
        maxUsers: maxUsers,
      );
      await updateUseCase(widget.goal.id, dto);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Objetivo actualizado'), backgroundColor: Colors.green),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Objetivo')),
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyTextField(
                      controller: _nameController,
                      hintText: 'Nombre del objetivo *',
                      obscureText: false,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'El nombre es obligatorio';
                        if (v.length > 255) return 'Máximo 255 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldMultiline(
                      controller: _descriptionController,
                      hintText: 'Descripción',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    MyDatePicker(
                      labelText: 'Fecha de inicio *',
                      selectedDate: _startDate,
                      onDateSelected: (d) => setState(() => _startDate = d),
                    ),
                    const SizedBox(height: 16),
                    MyDatePicker(
                      labelText: 'Fecha de fin *',
                      selectedDate: _endDate,
                      onDateSelected: (d) => setState(() => _endDate = d),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VerificationMethod>(
                      initialValue: _verificationMethod,
                      decoration: const InputDecoration(
                        labelText: 'Método de verificación',
                        border: OutlineInputBorder(),
                      ),
                      items: VerificationMethod.values.map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(_verificationLabel(v)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _verificationMethod = v!),
                    ),
                    const SizedBox(height: 16),
                    if (_categories.isNotEmpty) ...[
                      Text('Categorías (opcional)', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((c) {
                            final ok = _selectedCategoryIds.contains(c.id);
                            return FilterChip(
                              label: Text(c.name),
                              selected: ok,
                              onSelected: (s) {
                                setState(() {
                                  if (s) {
                                    _selectedCategoryIds.add(c.id);
                                  } else {
                                    _selectedCategoryIds.remove(c.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatorio';
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return 'Debe ser ≥ 1';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : () => _submit(context),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _verificationLabel(VerificationMethod v) {
    switch (v) {
      case VerificationMethod.qr:
        return 'QR';
      case VerificationMethod.checklist:
        return 'Checklist';
      case VerificationMethod.manual:
        return 'Manual';
      case VerificationMethod.externalApi:
        return 'API externa';
    }
  }
}
